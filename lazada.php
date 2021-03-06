<?php
namespace Controller;

require_once('inc/class/Product/Manager/ItemManager.php');
require_once('inc/class/Lazada/Manager/ItemManager.php');
require_once('inc/class/Product/Item.php');
require_once('inc/class/Orders/Record.php');
require_once('inc/class/Orders/Lazada/AutoFilling.php');
require_once('inc/class/HTML/TableDisplayer.php');
require_once('inc/class/IO/FileInputStream.php');
require_once('inc/class/IO/CSVInputStream.php');
require('../db/conn_staff.php');

use Product\Manager\ItemManager;
use HTML\TableDisplayer;
use IO\CSVInputStream;
use Orders\Lazada\AutoFilling;
use Exception;
use mysqli;

class LazadaOrdersController
{
    private $con;
    private $file;
    private $FILE;
    private $Data = [
        'toRestock' => '',
        'toCollect' => '',
        'notFound' => '',
        'orders' => ''
    ];
    public function __construct(mysqli $con, array $FILE)
    {
        if ($FILE['error'] !== 0) {
            throw new Exception('error on file: ' .$_FILES['lzdOrders']['name']);
        }
        $file = $FILE['tmp_name'];
        if (!file_exists($file)) {
            throw new Exception("file does not exist: {$file}.");
        }
        $this->con = $con;
        $this->file = $file;
        $this->FILE = $FILE;
    }

    public function getData():array
    {
        return $this->Data;
    }

    public function initData():void
    {
        $orders = $this->getOrders();

        $keyedSku = $this->getKeyedSku($orders);
        $keyeditemCodeStock = $this->getKeyedItemCode($keyedSku);
        $this->joinItemCodeToSku($keyedSku, $keyeditemCodeStock);
        $this->setItemsToData($keyedSku);

        $this->setShippingFeeByWeight($orders);
        $this->setOrdersToData($orders);
    }

    private function getOrders():array
    {
        $LAZADA_CSV_DELIMITER = ';';
        $in = new CSVInputStream($this->file, $LAZADA_CSV_DELIMITER);
        $orders = [];
        try {
            $orders = $in->readLines();
        } finally {
            $in->close();
        }
        if (count($orders) === 0) {
            throw new Exception("No data captured. Possible invalid file: {$this->file}.");
        }
        if (count($orders[0]) < 64) {
            throw new Exception('Too less columns. Invalid file: ' .$this->FILE['name']);
        }
        array_splice($orders, 0, 1);
        return array_map(function ($r) {
            return [
                'orderNum' => trim($r[8]),
                'date' => trim($r[7]),
                'sku' => trim($r[4]),
                'description' => trim($r[44]),
                'sellingPrice' => trim($r[41]),
                'shippingFee' => trim($r[42]),

                'paidPrice' => trim($r[40]),
                'shippingProvider' => trim($r[47]),
                'trackingNum' => trim($r[51]),
                'shippingState' => trim($r[21]),
                'stock' => null
            ];
        }, $orders);
    }
    private function getKeyedSku(array &$orders):array
    {
        //sku from all orders as index
        $keyedSku = [];
        foreach ($orders as $i => $r) {
            if (!array_key_exists($r['sku'], $keyedSku)) {
                $keyedSku[$r['sku']] = [];
            }
            $keyedSku[$r['sku']][] = &$orders[$i];
        }
        return $keyedSku;
    }
    private function getKeyedItemCode(array &$keyedSku):array
    {
        //item code from stock as index
        $IM = new ItemManager($this->con);
        $stockItems = $IM->selectByItemCode(array_keys($keyedSku));
        $keyItemCode = [];
        foreach ($stockItems as $r) {
            $keyItemCode[$r['item_code']] = [
                'description' => $r['description'],
                'stock' => (int)$r['quantity']
            ];
        }
        return $keyItemCode;
    }
    private function joinItemCodeToSku(array &$keyedSku, array &$keyedItemCode):void
    {
        foreach ($keyedItemCode as $itemCode => $r) {
            if (\array_key_exists($itemCode, $keyedSku)) {
                foreach ($keyedSku[$itemCode] as $i => $order) {
                    $keyedSku[$itemCode][$i]['description'] = $r['description'];
                    $keyedSku[$itemCode][$i]['stock'] = $r['stock'];
                }
            }
        }
    }
    private function setItemsToData(array &$keyedSku):void
    {
        $HEADER = [
            'sku' => 'Item Code',
            'description' => 'Description',
            'quantity' => 'Quantity',
            'stock' => 'Stock'
        ];
        $foundItems = [];
        $notFoundItems = [];
        foreach ($keyedSku as $r) {
            $order = $r[0];
            $order['quantity'] = count($r);
            if ($order['stock'] === null) {
                $notFoundItems[] = $order;
            } else {
                $foundItems[] = $order;
            }
        }

        $itemToRestock = [];
        $itemToCollect = [];
        foreach ($foundItems as $r) {
            if ($r['quantity'] >= $r['stock']) {
                $itemToRestock[] = $r;
            }
        }
        foreach ($foundItems as $r) {
            if ($r['quantity'] <= $r['stock']) {
                $itemToCollect[] = $r;
            }
        }

        $Tbl = new TableDisplayer();
        $Tbl->setHead($HEADER, true);
        
        $Tbl->setBody($itemToRestock);
        $this->Data['toRestock'] = $Tbl->getTable();
 
        $Tbl->setBody($itemToCollect);
        $this->Data['toCollect'] = $Tbl->getTable();

        $Tbl->setBody($notFoundItems);
        $this->Data['notFound'] = $Tbl->getTable();
    }
    private function setShippingFeeByWeight(array &$orders):void
    {
        $Records = array_map(function (array $r) {
            $Record = new \Orders\Record(
                null,
                $r['orderNum'],
                new \Product\Item(null, $r['sku'], null)
            );
            $Record->setShippingFee((double) $r['shippingFee']);
            $Record->setShippingState($r['shippingState']);
            $Record->setTrackingNum($r['trackingNum']);
            
            $Record->setDate($r['date']);
            return $Record;
        }, $orders);
        AutoFilling::setShippingWeightByLzdProduct($this->con, $Records);
        AutoFilling::setShippingFeeByWeight($Records);

        foreach ($Records as $i => $r) {
            if ($orders[$i]['orderNum'] !== $r->orderNum) {
                throw new Exception("cannot map shippingFeeByWeight to orders. iteration: {$i}");
            }
            $orders[$i]['shippingFeeByWeight'] = $r->shippingFeeByWeight;
            $orders[$i]['shippingWeight'] = $r->shippingWeight;
            $orders[$i]['date'] = $r->date;
        }
    }

    private function setOrdersToData(array &$orders):void
    {
        $Tbl = new TableDisplayer();

        $HEADER = [
            'orderNum' => 'Order Number',
            'date' => 'Date',
            'sku' => 'SKU',
            'description' => 'Description',
            'sellingPrice' => 'Selling Price',
            'shippingFee' => 'Shipping Fee',
            'shippingFeeByWeight' => 'Shipping Fee2',
            'shippingWeight' => 'Weight',

            'paidPrice' => 'Paid Price',
            'shippingProvider' => 'Shipping Provider',
            'trackingNum' => 'Tracking Number'
        ];
        $Tbl->setHead($HEADER, true);
        $Tbl->setBody($orders);
        $Tbl->setAttributes('id="lazadaOrders"');
        $this->Data['orders'] = $Tbl->getTable();
    }
}

$Data = [
    'toRestock' => '',
    'toCollect' => '',
    'notFound' => '',
    'orders' => ''
];
$msg = '';
try {
    if (isset($_FILES['lzdOrders'])) {
        try {
            $L = new LazadaOrdersController($con, $_FILES['lzdOrders']);
            $L->initData();
            $Data = $L->getData();
        } catch (Exception $e) {
            $msg = $e->getMessage();
        }
    }
} finally {
    $con->close();
}

require('view/lazada.html');
