<?php
namespace Orders\Factory\Excel;

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

final class SqlImport{
    public static function loadSpreadsheet(array $cashSalesEntries):Spreadsheet{
        
        // Create new Spreadsheet object
        $spreadsheet = new Spreadsheet();

        // Set document properties
        $spreadsheet->getProperties()->setCreator('cardeco')
            ->setLastModifiedBy('cardeco')
            ->setTitle('SQL Import File')
            ->setSubject('SQL Import File')
            ->setDescription('To import cash sales records')
            ->setKeywords('office 2007 openxml php')
            ->setCategory('Test result file');
        
        // Add some data
        $workSheet = $spreadsheet->setActiveSheetIndex(0);
        $workSheet->setTitle('Cash Sales');

        //set data to sheet
        self::setHeader(array_keys($cashSalesEntries[0] ?? []),  $workSheet);
        self::setAllData($cashSalesEntries, $workSheet);
        self::addStyle(2, count($cashSalesEntries), $workSheet);

        return $spreadsheet;

    }

    private static function setHeader(array $header, Worksheet $workSheet):void{
        $i=1;
        foreach($header as $v){
            //set header
            $workSheet->setCellValueByColumnAndRow($i, 1, $v);
            
            //add style
            $workSheet->getColumnDimensionByColumn($i)->setAutoSize(true);
            
            $style = $workSheet->getCellByColumnAndRow($i,1)->getStyle();
            
            $style->getFill()
            ->setFillType(\PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID)
            ->getStartColor()->setARGB(\PhpOffice\PhpSpreadsheet\Style\Color::COLOR_YELLOW);
            
            $style->getFont()
            ->setBold(true);
            $i += 1;
        }
        $workSheet->getRowDimension(1)->setRowHeight(24);
    }

    private static function setAllData(array $list, Worksheet $workSheet):void{
        $i = 2;
        foreach($list as $r){
            $c = 1;
            foreach($r as $col){
                $workSheet->setCellValueByColumnAndRow($c++, $i, $col);
            }
            $i += 1;
        }
    }

    private static function addStyle(int $beginRowPos, int $lastRowPos, Worksheet $workSheet):void{
        $uomPos = 12;
        $docRefPos = 22;

        for($i=$beginRowPos;$i<=$lastRowPos;++$i){
            $cell = $workSheet->getCellByColumnAndRow($uomPos, $i);
            if($cell->getValue() === null){
                $cell->getStyle()
                ->getFill()
                ->setFillType(\PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID)
                ->getStartColor()->setARGB(\PhpOffice\PhpSpreadsheet\Style\Color::COLOR_RED);
            }

            $workSheet->getCellByColumnAndRow($docRefPos, $i)->getStyle()
            ->getNumberFormat()->setFormatCode(\PhpOffice\PhpSpreadsheet\Style\NumberFormat::FORMAT_NUMBER);
        }
    }

    
}
