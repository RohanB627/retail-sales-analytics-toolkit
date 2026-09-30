Attribute VB_Name = "FormatMonthlySalesReport"
'==============================================================
' FormatMonthlySalesReport
' Retail Sales Planning & Analytics Toolkit
'
' Applies standard report formatting to the unpivoted monthly
' sales table produced by Power Query (Unpivot Other Columns on
' "Monthly Sales (Wide)"). Uses a dynamically calculated LastRow
' rather than hardcoded row numbers, so it works correctly no
' matter how many product/month rows the current export contains.
'==============================================================
Sub FormatMonthlySalesReport()
    Dim LastRow As Long
    LastRow = Cells(Rows.Count, 1).End(xlUp).Row

    ' Bold header row
    Range("A1:C1").Select
    Selection.Font.Bold = True

    ' Auto-fit all columns to content
    Cells.Select
    Cells.EntireColumn.AutoFit

    ' Add a dynamic Total row directly beneath the last data row
    Range("A" & LastRow + 1).Select
    ActiveCell.Value = "Total"

    Range("C" & LastRow + 1).Select
    ActiveCell.Formula = "=SUM(C2:C" & LastRow & ")"

    ' Currency formatting on the Revenue column, including the Total row
    Range("C2:C" & LastRow + 1).Select
    Selection.NumberFormat = "£#,##0.00"

    ' Borders around the full table
    Range("A1:C" & LastRow + 1).Select
    Selection.Borders.LineStyle = xlContinuous

    ' Bold the Total row
    Range("A" & LastRow + 1 & ":C" & LastRow + 1).Select
    Selection.Font.Bold = True

    MsgBox "Formatted " & LastRow - 1 & " rows. Total row added at row " & LastRow + 1 & "."
End Sub
