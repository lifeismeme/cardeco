CashSaleSqlImport.php[36m:[m[1;31m<?php
CashSaleSqlImport.php[36m:[m[1;31mnamespace main;
CashSaleSqlImport.php[36m:[m[1;31m
CashSaleSqlImport.php[36m:[m[1;31mrequire('vendor/autoload.php');
CashSaleSqlImport.php[36m:[m[1;31mrequire('../db/conn_staff.php');
CashSaleSqlImport.php[36m:[m[1;31m
CashSaleSqlImport.php[36m:[m[1;31muse Exception;
CashSaleSqlImport.php[36m:[m[1;31muse InvalidArgumentException;
CashSaleSqlImport.php[36m:[m[1;31muse Orders\Factory\Excel\CashSales;
CashSaleSqlImport.php[36m:[m[1;31muse Orders\Factory\Excel\SqlImport;
CashSaleSqlImport.php[36m:[m[1;31muse Orders\Factory\Excel\ExcelReader;
CashSaleSqlImport.php[36m:[m[1;31muse PhpOffice\PhpSpreadsheet\IOFactory;
CashSaleSqlImport.php[36m:[m[1;31m
CashSaleSqlImport.php[36m:[m[1;31mfunction validateFile(array $file):void
CashSaleSqlImport.php[36m:[m[1;31m{
CashSaleSqlImport.php[36m:[m[1;31m    if (count($file) !== 5) {
CashSaleSqlImport.php[36m:[m[1;31m        throw new InvalidArgumentException('expected $_FILES[0]');
CashSaleSqlImport.php[36m:[m[1;31m    }
CashSaleSqlImport.php[36m:[m[1;31m    
CashSaleSqlImport.php[36m:[m[1;31m    if ($file['error'] !== 0) {
CashSaleSqlImport.php[36m:[m[1;31m        throw new Exception('file upload error.');
CashSaleSqlImport.php[36m:[m[1;31m    }
CashSaleSqlImport.php[36m:[m[1;31m
CashSaleSqlImport.php[36m:[m[1;31m    $uploadedFileExt = pathinfo(basename($file['name']), PATHINFO_EXTENSION);
CashSaleSqlImport.php[36m:[m[1;31m    if ($uploadedFileExt !== 'xlsx') {
CashSaleSqlImport.php[36m:[m[1;31m        throw new Exception('invalid file extension: ' .$uploadedFileExt);
CashSaleSqlImport.php[36m:[m[1;31m    }
CashSaleSqlImport.php[36m:[m[1;31m}
CashSaleSqlImport.php[36m:[m[1;31m
CashSaleSqlImport.php[36m:[m[1;31m$errmsg = '';
CashSaleSqlImport.php[36m:[m[1;31mtry {
CashSaleSqlImport.php[36m:[m[1;31m    if (isset($_POST['fileTab']) && isset($_FILES['dataFile'])) {
CashSaleSqlImport.php[36m:[m[1;31m        $file =& $_FILES['dataFile'];
CashSaleSqlImport.php[36m:[m[1;31m        $fileTab = $_POST['fileTab'] ?? null;
CashSaleSqlImport.php[36m:[m[1;31m        $startRowPos = $_POST['startRowPos'] ?? 1;
CashSaleSqlImport.php[36m:[m[1;31m        $lastRowPos = $_POST['lastRowPos'] ?? -1;
CashSaleSqlImport.php[36m:[m[1;31m        $lastRowPos = intval($lastRowPos);
CashSaleSqlImport.php[36m:[m[1;31m
CashSaleSqlImport.php[36m:[m[1;31m        validateFile($file);
CashSaleSqlImport.php[36m:[m[1;31m
CashSaleSqlImport.php[36m:[m[1;31m        $list = CashSales::transformToCashSales($con, $fileTab, ExcelReader::fetch($file['tmp_name'], $fileTab, $startRowPos, $lastRowPos));
CashSaleSqlImport.php[36m:[m[1;31m        $Spreadsheet = SqlImport::loadSpreadsheet($list);
CashSaleSqlImport.php[36m:[m[1;31m        if (error_get_last() !== null) {
CashSaleSqlImport.php[36m:[m[1;31m            http_response_code(500);
CashSaleSqlImport.php[36m:[m[1;31m            throw new Exception('Some Errors have occoured.');
CashSaleSqlImport.php[36m:[m[1;31m        }
CashSaleSqlImport.php[36m:[m[1;31m
CashSaleSqlImport.php[36m:[m[1;31m        // Redirect output to a client’s web browser (Xlsx)
CashSaleSqlImport.php[36m:[m[1;31m        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
CashSaleSqlImport.php[36m:[m[1;31m        header('Content-Disposition: attachment;filename="CashSales for SQL Import.xlsx"');
CashSaleSqlImport.php[36m:[m[1;31m        header('Cache-Control: max-age=0');
CashSaleSqlImport.php[36m:[m[1;31m        // If you're serving to IE 9, then the following may be needed
CashSaleSqlImport.php[36m:[m[1;31m        header('Cache-Control: max-age=1');
CashSaleSqlImport.php[36m:[m[1;31m    
CashSaleSqlImport.php[36m:[m[1;31m        // If you're serving to IE over SSL, then the following may be needed
CashSaleSqlImport.php[36m:[m[1;31m        header('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
CashSaleSqlImport.php[36m:[m[1;31m        header('Last-Modified: ' . gmdate('D, d M Y H:i:s') . ' GMT'); // always modified
CashSaleSqlImport.php[36m:[m[1;31m        header('Cache-Control: cache, must-revalidate'); // HTTP/1.1
CashSaleSqlImport.php[36m:[m[1;31m        header('Pragma: public'); // HTTP/1.0
CashSaleSqlImport.php[36m:[m[1;31m    
CashSaleSqlImport.php[36m:[m[1;31m        $writer = IOFactory::createWriter($Spreadsheet, 'Xlsx');
CashSaleSqlImport.php[36m:[m[1;31m        $writer->save('php://output');
CashSaleSqlImport.php[36m:[m[1;31m        exit();
CashSaleSqlImport.php[36m:[m[1;31m    }
CashSaleSqlImport.php[36m:[m[1;31m} catch (Exception $e) {
CashSaleSqlImport.php[36m:[m[1;31m    $errmsg = $e->getMessage();
CashSaleSqlImport.php[36m:[m[1;31m} finally {
CashSaleSqlImport.php[36m:[m[1;31m    $con->close();
CashSaleSqlImport.php[36m:[m[1;31m}
CashSaleSqlImport.php[36m:[m[1;31m
CashSaleSqlImport.php[36m:[m[1;31mrequire('view/CashsaleSqlImport.html');
Cashsale.php[36m:[m[1;31m<?php 
Cashsale.php[36m:[m[1;31mnamespace main;
Cashsale.php[36m:[m[1;31m
Cashsale.php[36m:[m[1;31mrequire_once('inc/class/Orders/Factory/Cashsale.php');
Cashsale.php[36m:[m[1;31mrequire_once(__DIR__ .'/../db/conn_staff.php');
Cashsale.php[36m:[m[1;31m
Cashsale.php[36m:[m[1;31muse \Orders\Factory\Cashsale;
Cashsale.php[36m:[m[1;31muse \Exception;
Cashsale.php[36m:[m[1;31m
Cashsale.php[36m:[m[1;31m$msg = '';
Cashsale.php[36m:[m[1;31mtry{
Cashsale.php[36m:[m[1;31m    if(isset($_POST['dateStockOut'])){
Cashsale.php[36m:[m[1;31m        try{
Cashsale.php[36m:[m[1;31m            $CF = new Cashsale($con);
Cashsale.php[36m:[m[1;31m            $CF->setMonthlyRecordByDateStockOut($_POST['dateStockOut']);
Cashsale.php[36m:[m[1;31m            
Cashsale.php[36m:[m[1;31m            $list = $CF->generateRecords();
Cashsale.php[36m:[m[1;31m            $list = array_map(function($r){
Cashsale.php[36m:[m[1;31m                return $r->getData();
Cashsale.php[36m:[m[1;31m            }, $list);
Cashsale.php[36m:[m[1;31m        
Cashsale.php[36m:[m[1;31m            $MainFolder = 'public/txtImport_file2/';
Cashsale.php[36m:[m[1;31m            $targetFolder = $MainFolder .date('Y') .'/' .date('M') . '/' .date('d');
Cashsale.php[36m:[m[1;31m            $Date_NOW = date('d-m-Y');
Cashsale.php[36m:[m[1;31m            $fileName = '';
Cashsale.php[36m:[m[1;31m            if(!is_writeable($MainFolder)){
Cashsale.php[36m:[m[1;31m                throw new Exception("Unable to write file. have no permission write to dir: {$targetFolder}.");
Cashsale.php[36m:[m[1;31m            }
Cashsale.php[36m:[m[1;31m            if(!file_exists($targetFolder)){
Cashsale.php[36m:[m[1;31m                mkdir($targetFolder, 0777, true);
Cashsale.php[36m:[m[1;31m            }
Cashsale.php[36m:[m[1;31m            $i = 0;
Cashsale.php[36m:[m[1;31m        
Cashsale.php[36m:[m[1;31m            foreach($list as $file){
Cashsale.php[36m:[m[1;31m                $fileName = $Date_NOW . '_' . time() . "({$i})";
Cashsale.php[36m:[m[1;31m                
Cashsale.php[36m:[m[1;31m                $out = fopen("{$targetFolder}/{$fileName}.txt", 'wb');
Cashsale.php[36m:[m[1;31m                if($out === false){
Cashsale.php[36m:[m[1;31m                    throw new Exception("Unable to open file {$targetFolder}/{$fileName}.txt");
Cashsale.php[36m:[m[1;31m                }
Cashsale.php[36m:[m[1;31m                try{
Cashsale.php[36m:[m[1;31m                    if(!fwrite($out, $file)){
Cashsale.php[36m:[m[1;31m                        throw new Exception('Fail to write File ');
Cashsale.php[36m:[m[1;31m                    }
Cashsale.php[36m:[m[1;31m                }finally{
Cashsale.php[36m:[m[1;31m                    fclose($out);
Cashsale.php[36m:[m[1;31m                }
Cashsale.php[36m:[m[1;31m                ++$i;
Cashsale.php[36m:[m[1;31m            }
Cashsale.php[36m:[m[1;31m            header('HTTP/1.1 200');
Cashsale.php[36m:[m[1;31m            $msg = '<script>alert("Cash sales files exported at: [server]/public/ folder.")</script>';
Cashsale.php[36m:[m[1;31m        }catch(Exception $e){
Cashsale.php[36m:[m[1;31m            header('HTTP/1.1 500');
Cashsale.php[36m:[m[1;31m            $msg = htmlspecialchars($e->getMessage(), ENT_QUOTES);
Cashsale.php[36m:[m[1;31m        }
Cashsale.php[36m:[m[1;31m    }
Cashsale.php[36m:[m[1;31m}finally{
Cashsale.php[36m:[m[1;31m    $con->close();
Cashsale.php[36m:[m[1;31m}
Cashsale.php[36m:[m[1;31m
Cashsale.php[36m:[m[1;31mrequire('view/Cashsale.html')
Cashsale.php[36m:[m[1;31m?>[m
ItemManager.php[36m:[m[1;31m<?php 
ItemManager.php[36m:[m[1;31mnamespace main;
ItemManager.php[36m:[m[1;31m
ItemManager.php[36m:[m[1;31mrequire_once('inc/class/Product/ItemManager.php');
ItemManager.php[36m:[m[1;31mrequire_once('inc/class/Product/ItemEditor.php');
ItemManager.php[36m:[m[1;31mrequire_once('inc/class/Product/Item.php');
ItemManager.php[36m:[m[1;31mrequire_once(__DIR__ .'/../db/conn_staff.php');
ItemManager.php[36m:[m[1;31m
ItemManager.php[36m:[m[1;31muse \Orders\MonthlyRecord;
ItemManager.php[36m:[m[1;31muse \Product\ItemEditor;
ItemManager.php[36m:[m[1;31muse \Product\ItemManager;
ItemManager.php[36m:[m[1;31muse \Product\Item;
ItemManager.php[36m:[m[1;31m
ItemManager.php[36m:[m[1;31m$itemEditor = '';
ItemManager.php[36m:[m[1;31m$error = '';
ItemManager.php[36m:[m[1;31mtry{
ItemManager.php[36m:[m[1;31m    try{
ItemManager.php[36m:[m[1;31m        if(isset($_GET['itemCode'])){
ItemManager.php[36m:[m[1;31m            $ItemM = new ItemManager($con);
ItemManager.php[36m:[m[1;31m            $ItemEditor = new ItemEditor();
ItemManager.php[36m:[m[1;31m
ItemManager.php[36m:[m[1;31m            $ItemEditor->setItems(
ItemManager.php[36m:[m[1;31m                $ItemM->getItemLikeItemCode($_GET['itemCode']), 
ItemManager.php[36m:[m[1;31m                0
ItemManager.php[36m:[m[1;31m            );
ItemManager.php[36m:[m[1;31m
ItemManager.php[36m:[m[1;31m            $itemEditor = $ItemEditor->getTable();
ItemManager.php[36m:[m[1;31m        }
ItemManager.php[36m:[m[1;31m
ItemManager.php[36m:[m[1;31m        if(isset($_POST['r'])){
ItemManager.php[36m:[m[1;31m            $ItemM = new ItemManager($con);
ItemManager.php[36m:[m[1;31m            $Items = [];
ItemManager.php[36m:[m[1;31m            foreach($_POST['r'] as $itemId => $r){
ItemManager.php[36m:[m[1;31m                $Items[] = new Item($itemId, null, $r['description']);
ItemManager.php[36m:[m[1;31m            }
ItemManager.php[36m:[m[1;31m            $ItemM->update($Items);
ItemManager.php[36m:[m[1;31m            header('HTTP/1.1 205');
ItemManager.php[36m:[m[1;31m        }
ItemManager.php[36m:[m[1;31m    }finally{
ItemManager.php[36m:[m[1;31m        $con->close();
ItemManager.php[36m:[m[1;31m    }
ItemManager.php[36m:[m[1;31m}catch(\Exception $e){
ItemManager.php[36m:[m[1;31m    $error = $e->getMessage();
ItemManager.php[36m:[m[1;31m}
ItemManager.php[36m:[m[1;31m
ItemManager.php[36m:[m[1;31mrequire('view/ItemManager.html');
ItemManager.php[36m:[m[1;31m?>[m
LzdFeeChecker.php[36m:[m[1;31m<?php
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31mnamespace main;
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31mrequire_once 'inc/class/Orders/Factory/Record.php';
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31mrequire_once 'inc/class/Orders/PaymentCharges/PlatformCharges.php';
LzdFeeChecker.php[36m:[m[1;31mrequire_once 'inc/class/Lazada/Manager/Fee_StatementsManager.php';
LzdFeeChecker.php[36m:[m[1;31mrequire_once 'inc/class/Lazada/Manager/OrdersManager.php';
LzdFeeChecker.php[36m:[m[1;31mrequire_once 'inc/class/Lazada/Factory/LzdFeeStatementFactory.php';
LzdFeeChecker.php[36m:[m[1;31mrequire_once 'inc/class/Lazada/FeeStatement.php';
LzdFeeChecker.php[36m:[m[1;31mrequire_once 'inc/class/HTML/TableDisplayer.php';
LzdFeeChecker.php[36m:[m[1;31mrequire_once 'inc/class/IO/FileInputStream.php';
LzdFeeChecker.php[36m:[m[1;31mrequire_once 'inc/class/IO/CSVInputStream.php';
LzdFeeChecker.php[36m:[m[1;31mrequire_once __DIR__ . '/../db/conn_staff.php';
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31muse \Lazada\Manager\Fee_StatementsManager;
LzdFeeChecker.php[36m:[m[1;31muse \Lazada\Manager\OrdersManager;
LzdFeeChecker.php[36m:[m[1;31muse \Lazada\Factory\LzdFeeStatementFactory;
LzdFeeChecker.php[36m:[m[1;31muse \HTML\TableDisplayer;
LzdFeeChecker.php[36m:[m[1;31muse \IO\CSVInputStream;
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m$errormsg = '';
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m$tbl = new TableDisplayer();
LzdFeeChecker.php[36m:[m[1;31mtry {
LzdFeeChecker.php[36m:[m[1;31m    if (isset($_POST['btnSubmit']['uploadLzdFeeStmt']) && isset($_FILES['file_LzdFeeStmt']) && $_FILES['file_LzdFeeStmt']['error'] === 0) {
LzdFeeChecker.php[36m:[m[1;31m        $file = new CSVInputStream($_FILES['file_LzdFeeStmt']['tmp_name']);
LzdFeeChecker.php[36m:[m[1;31m        $list = $file->readLines();
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m        \array_splice($list, 0, 1);
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m        $records = LzdFeeStatementFactory::getFeeStatementList($list);
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m        $con->autoCommit(false);
LzdFeeChecker.php[36m:[m[1;31m        Fee_StatementsManager::insertRecords($con, $records, $_SERVER['REMOTE_ADDR']);
LzdFeeChecker.php[36m:[m[1;31m        $con->commit();
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m        header('Location: fee_statement.php');
LzdFeeChecker.php[36m:[m[1;31m    }
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m    if (isset($_POST['btnSubmit']['checkLzdFeeStmt'])) {
LzdFeeChecker.php[36m:[m[1;31m        $paymentAmounts = Fee_StatementsManager::getOrderNumPaymentAmount($con, $_SERVER['REMOTE_ADDR']);
LzdFeeChecker.php[36m:[m[1;31m        $shippingFeeByCusts = Fee_StatementsManager::getOrderNumShippingFeeByCust($con, $_SERVER['REMOTE_ADDR']);
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m        $orders = OrdersManager::getForLzdFeeStmtByOrderNums($con, \array_keys($paymentAmounts));
LzdFeeChecker.php[36m:[m[1;31m        foreach ($orders as $i => $r) {
LzdFeeChecker.php[36m:[m[1;31m            $orders[$i]['grandTotal'] = $r['sellingPrice'] + $r['shippingFeeByCust'] - $r['voucher'] - $r['platformChargesAmount'];
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m            if (\array_key_exists($r['orderNum'], $paymentAmounts) === true) {
LzdFeeChecker.php[36m:[m[1;31m                $orders[$i]['stmtPaymentAmount'] = $paymentAmounts[$r['orderNum']];
LzdFeeChecker.php[36m:[m[1;31m            }
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m            if (\array_key_exists($r['orderNum'], $shippingFeeByCusts) === true) {
LzdFeeChecker.php[36m:[m[1;31m                $orders[$i]['stmtShippingFeeByCust'] = $shippingFeeByCusts[$r['orderNum']];
LzdFeeChecker.php[36m:[m[1;31m            }
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m            $orders[$i]['grantTotalDiff'] = $orders[$i]['grandTotal'] - $orders[$i]['stmtPaymentAmount'] - $orders[$i]['stmtShippingFeeByCust'];
LzdFeeChecker.php[36m:[m[1;31m        }
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m        $header = [];
LzdFeeChecker.php[36m:[m[1;31m        $header['billno'] = 'Bill no';
LzdFeeChecker.php[36m:[m[1;31m        $header['orderNum'] = 'Order Number';
LzdFeeChecker.php[36m:[m[1;31m        $header['sellingPrice'] = 'Selling Price';
LzdFeeChecker.php[36m:[m[1;31m        $header['shippingFeeByCust'] = 'Courier By Customer';
LzdFeeChecker.php[36m:[m[1;31m        $header['voucher'] = 'Voucher';
LzdFeeChecker.php[36m:[m[1;31m        $header['platformChargesAmount'] = 'Platform Charges';
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m        $header['grandTotal'] = 'Grand Total';
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m        $header['stmtPaymentAmount'] = 'Payment Amount';
LzdFeeChecker.php[36m:[m[1;31m        $header['stmtShippingFeeByCust'] = 'Shipping Fee';
LzdFeeChecker.php[36m:[m[1;31m        $header['grantTotalDiff'] = 'Grand Total Difference';
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m        $tbl->setHead($header);
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m        $tbl->setBody($orders);
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31m        $tbl->setBody($orders);
LzdFeeChecker.php[36m:[m[1;31m    }
LzdFeeChecker.php[36m:[m[1;31m} catch (\Exception $e) {
LzdFeeChecker.php[36m:[m[1;31m    $con->rollback();
LzdFeeChecker.php[36m:[m[1;31m    $errormsg = $e->getMessage();
LzdFeeChecker.php[36m:[m[1;31m} finally {
LzdFeeChecker.php[36m:[m[1;31m    $con->close();
LzdFeeChecker.php[36m:[m[1;31m}
LzdFeeChecker.php[36m:[m[1;31m
LzdFeeChecker.php[36m:[m[1;31mrequire 'view/LzdFeeChecker.html';
LzdItemManager.php[36m:[m[1;31m<?php 
LzdItemManager.php[36m:[m[1;31mnamespace main;
LzdItemManager.php[36m:[m[1;31m
LzdItemManager.php[36m:[m[1;31mrequire_once('inc/class/Lazada/Item.php');
LzdItemManager.php[36m:[m[1;31mrequire_once('inc/class/Lazada/Manager/ItemManager.php');
LzdItemManager.php[36m:[m[1;31mrequire_once('inc/class/Lazada/Factory/LzdItemFactory.php');
LzdItemManager.php[36m:[m[1;31mrequire_once(__DIR__ .'/../db/conn_staff.php');
LzdItemManager.php[36m:[m[1;31m
LzdItemManager.php[36m:[m[1;31muse Lazada\Item;
LzdItemManager.php[36m:[m[1;31muse Lazada\Factory\LzdItemFactory;
LzdItemManager.php[36m:[m[1;31muse Lazada\Manager\ItemManager;
LzdItemManager.php[36m:[m[1;31m
LzdItemManager.php[36m:[m[1;31m$msg = '';
LzdItemManager.php[36m:[m[1;31m$errorMsg = '';
LzdItemManager.php[36m:[m[1;31mtry{
LzdItemManager.php[36m:[m[1;31m    try{
LzdItemManager.php[36m:[m[1;31m        if(isset($_FILES['LzdProducts'])){
LzdItemManager.php[36m:[m[1;31m            if($_FILES['LzdProducts']['error'] !== 0){
LzdItemManager.php[36m:[m[1;31m                throw new Exception("File has error.");
LzdItemManager.php[36m:[m[1;31m            }
LzdItemManager.php[36m:[m[1;31m            $file = $_FILES['LzdProducts']['tmp_name'];
LzdItemManager.php[36m:[m[1;31m            $Fac = new LzdItemFactory($file);
LzdItemManager.php[36m:[m[1;31m            $list = $Fac->generateRecords();
LzdItemManager.php[36m:[m[1;31m
LzdItemManager.php[36m:[m[1;31m            $M = new ItemManager($con);
LzdItemManager.php[36m:[m[1;31m            $existingLzdSku_temp = $M->selectAll('lzd_sku');
LzdItemManager.php[36m:[m[1;31m            $existingLzdSku = [];
LzdItemManager.php[36m:[m[1;31m            foreach($existingLzdSku_temp as $r){
LzdItemManager.php[36m:[m[1;31m                $existingLzdSku[$r['lzd_sku']] = null;
LzdItemManager.php[36m:[m[1;31m            }
LzdItemManager.php[36m:[m[1;31m            unset($existingLzdSku_temp);
LzdItemManager.php[36m:[m[1;31m
LzdItemManager.php[36m:[m[1;31m            //split
LzdItemManager.php[36m:[m[1;31m            $listToUpdate = [];
LzdItemManager.php[36m:[m[1;31m            $listToInsert = [];
LzdItemManager.php[36m:[m[1;31m            foreach($list as $Item){
LzdItemManager.php[36m:[m[1;31m                if(\array_key_exists($Item->lzdSku, $existingLzdSku)){
LzdItemManager.php[36m:[m[1;31m                    $listToUpdate[] = $Item;
LzdItemManager.php[36m:[m[1;31m                } else {
LzdItemManager.php[36m:[m[1;31m                    $listToInsert[] = $Item;
LzdItemManager.php[36m:[m[1;31m                }
LzdItemManager.php[36m:[m[1;31m            }
LzdItemManager.php[36m:[m[1;31m        
LzdItemManager.php[36m:[m[1;31m            //update
LzdItemManager.php[36m:[m[1;31m            $con->begin_transaction();
LzdItemManager.php[36m:[m[1;31m            try{
LzdItemManager.php[36m:[m[1;31m                $M->updateByLzdSku($listToUpdate);
LzdItemManager.php[36m:[m[1;31m                $M->insert($listToInsert);
LzdItemManager.php[36m:[m[1;31m                $con->commit();
LzdItemManager.php[36m:[m[1;31m                $msg = 'Product info updated.';
LzdItemManager.php[36m:[m[1;31m            }catch(\Exception $e){
LzdItemManager.php[36m:[m[1;31m                $con->rollback();
LzdItemManager.php[36m:[m[1;31m                throw $e;
LzdItemManager.php[36m:[m[1;31m            }
LzdItemManager.php[36m:[m[1;31m        }
LzdItemManager.php[36m:[m[1;31m    }finally{
LzdItemManager.php[36m:[m[1;31m        $con->close();
LzdItemManager.php[36m:[m[1;31m    }
LzdItemManager.php[36m:[m[1;31m}catch(\Exception $e){
LzdItemManager.php[36m:[m[1;31m    $errorMsg = \htmlspecialchars($e->getMessage(), ENT_QUOTES);
LzdItemManager.php[36m:[m[1;31m}
LzdItemManager.php[36m:[m[1;31mrequire('view/LzdItemManager.html');
LzdItemManager.php[36m:[m[1;31m?>[m