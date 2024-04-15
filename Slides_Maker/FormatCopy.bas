Attribute VB_Name = "Module1"
Sub FormatCopy()
Attribute FormatCopy.VB_ProcData.VB_Invoke_Func = " \n14"
'
' Format Copy

    Sheets("Main").Select
    Sheets("Main").Copy Before:=Sheets(2)
    
    Dim wsOriginal As Worksheet

    Set wsOriginal = ThisWorkbook.ActiveSheet

    wsOriginal.Cells.Copy

    wsOriginal.Cells.PasteSpecial Paste:=xlPasteValues

    Application.CutCopyMode = False


    range("7:7,11:13,17:20").Select
    range("A17").Activate
    range("7:7,11:13,17:20").EntireRow.AutoFit
    range("C7").Select
    Dim CurrentRowHeight As Single, MergedCellRgWidth As Single
    Dim CurrCell As range
    Dim ActiveCellWidth As Single, PossNewRowHeight As Single
    If ActiveCell.MergeCells Then
    With ActiveCell.MergeArea
    If .Rows.Count = 1 And .WrapText = True Then
    Application.ScreenUpdating = False
    CurrentRowHeight = .RowHeight
    ActiveCellWidth = ActiveCell.ColumnWidth
    For Each CurrCell In Selection
    MergedCellRgWidth = CurrCell.ColumnWidth + _
    MergedCellRgWidth
    Next
    .MergeCells = False
    .Cells(1).ColumnWidth = MergedCellRgWidth
    .EntireRow.AutoFit
    PossNewRowHeight = .RowHeight
    .Cells(1).ColumnWidth = ActiveCellWidth
    .MergeCells = True
    .RowHeight = IIf(CurrentRowHeight > PossNewRowHeight, _
    CurrentRowHeight, PossNewRowHeight)
    End If
    End With
    End If
    range("J1").Select
    Sheets("Main").Select
    range("M1").Select
    Selection.Copy
    range("J1").Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
End Sub
