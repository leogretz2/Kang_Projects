Attribute VB_Name = "Test_Macro"

Sub FormatCopyAutomated()

    Dim dataWS As Worksheet
    Dim coverWS As Worksheet
    Set dataWS = ThisWorkbook.Sheets("Data")
    Set coverWS = ThisWorkbook.Sheets("Cover")
    Dim ppApp As PowerPoint.Application
    Dim ppPres As PowerPoint.Presentation
    Dim pptPath As String
        
    Dim lastRow As Long
    Dim rowsFilled As Long
    Dim i As Long
    Dim companyInfo() As Variant
    
    ' Make ppApp and Pres, send to sheets
    Set ppApp = CreateObject("PowerPoint.Application")
    ppApp.Visible = True ' Make PowerPoint visible
    Set ppPres = ppApp.Presentations.Add
    pptPath = ThisWorkbook.Path & "\Weekly_5s_Review_" & Replace(Date, "/", "") & ".pptx"
    
    ' Find the last row of the table
    lastRow = dataWS.Cells(dataWS.Rows.Count, 1).End(xlUp).Row
    
    ReDim companyInfo(1 To lastRow, 1 To 2)
    rowsFilled = 0
    
    For i = 2 To lastRow ' Assuming row 1 has headers
        Dim rowData As New CompanyData
        RowToNewSheet dataWS, i, rowData, ppPres, pptPath, lastRow
        
        ' Add company info from rowData to company info array
        companyInfo(i - 1, 1) = rowData.CompanyName
        companyInfo(i - 1, 2) = rowData.UpgradedBy
        rowsFilled = rowsFilled + 1

    Next i
    
    ' Populate and export cover page
    PopulateCover coverWS, companyInfo, rowsFilled
    ConsolidatedPowerPointExport "Cover", ppPres, rowsFilled, pptPath, 20, 40, 1
    
    ' Clean up
    Set ppPres = Nothing
    ppApp.Quit
    Set ppApp = Nothing
    MsgBox "Done"
    
End Sub

Sub RowToNewSheet(ws As Worksheet, Row As Variant, rowData As CompanyData, ppPres As PowerPoint.Presentation, pptPath As String, NumCompanies As Long)
    
    ' Construct CompanyData
    ConstructCompanyData ws, Row, rowData
    
    ' Create a new sheet or get the existing one and assign it to a Worksheet variable
    Dim newSheet As Worksheet
    Set newSheet = CreateNewSheet(rowData.CompanyName)
    
    ' Assign values to new Sheet and export
    AssignValuesToSheet newSheet, rowData
    ConsolidatedPowerPointExport rowData.CompanyName, ppPres, NumCompanies, pptPath, 0, 50, ppPres.Slides.Count + 1
    
        
End Sub

Sub ConstructCompanyData(ws As Worksheet, i As Variant, rowData As CompanyData)

    With rowData
        .CompanyName = ws.Cells(i, 4).Value 'Column D
        .UpgradedBy = ws.Cells(i, 7).Value 'Column G
        .Description = ws.Cells(i, 29).Value 'Column AC
        
        .ScaleNotes = ws.Cells(i, 21).Value 'Column U
        .GrowthNotes = ws.Cells(i, 22).Value 'Column V
        .ProfitabilityNotes = ws.Cells(i, 23).Value 'Column W
        .RevenueModelNotes = ws.Cells(i, 24).Value ' Column X
        .OwnershipDynamicNotes = ws.Cells(i, 25).Value 'Column Y
        .ConcentrationsNotes = ws.Cells(i, 26).Value 'Column Z
        
        .CompanyOwner = ws.Cells(i, 5).Value 'Column E
        .Team = ws.Cells(i, 6).Value 'Column F
        .ProspectSource = ws.Cells(i, 15).Value 'Column O
        .SplitCredit = ws.Cells(i, 16).Value 'Column P
        .Website = ws.Cells(i, 35).Value 'Column AI
        
        .HQ = ws.Cells(i, 36).Value 'Column AJ
        .Employees = ws.Cells(i, 30).Value 'Column AD
        .LatestRaised = IIf(ws.Cells(i, 31).Value = 0, "", ws.Cells(i, 31).Value) 'Column AE
        .LatestRaisedDate = ws.Cells(i, 32).Value 'Column AF
        .TotalRaised = ws.Cells(i, 33).Value 'Column AG
    End With

End Sub

Function CreateNewSheet(SheetName As String) As Worksheet
    Dim ws As Worksheet
    
    ' Check if the sheet already exists
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(SheetName)
    On Error GoTo 0
    
    ' If the sheet does not exist, create it
    If ws Is Nothing Then
        ' Copy the "Main" sheet and place the copy before the second sheet in the workbook
        ThisWorkbook.Sheets("Main").Copy Before:=ThisWorkbook.Sheets(2)
        ActiveSheet.Name = SheetName
        Set ws = ActiveSheet

    End If
    
    ' Return the worksheet object
    Set CreateNewSheet = ws
End Function

Sub AssignValuesToSheet(targetSheet As Worksheet, rowData As CompanyData)
    If Not targetSheet Is Nothing Then
        If Not targetSheet.ProtectionMode Then

            targetSheet.Cells(2, 3).Value = rowData.CompanyName
            targetSheet.Cells(3, 3).Value = "Upgraded By " & rowData.UpgradedBy
            targetSheet.Cells(7, 3).Value = rowData.Description
            
            targetSheet.Cells(11, 4).Value = rowData.ScaleNotes
            targetSheet.Cells(12, 4).Value = rowData.GrowthNotes
            targetSheet.Cells(13, 4).Value = rowData.ProfitabilityNotes
            targetSheet.Cells(11, 7).Value = rowData.RevenueModelNotes
            targetSheet.Cells(12, 7).Value = rowData.OwnershipDynamicNotes
            targetSheet.Cells(13, 7).Value = rowData.ConcentrationsNotes
            
            Dim middleText As String

            If Len(rowData.Team) = 0 Then
                middleText = ""
            Else
                middleText = ", "
            End If
            targetSheet.Cells(17, 4).Value = rowData.CompanyOwner & middleText & rowData.Team
            targetSheet.Cells(18, 4).Value = rowData.ProspectSource
            targetSheet.Cells(19, 4).Value = rowData.SplitCredit
            targetSheet.Cells(20, 4).Value = rowData.Website
            targetSheet.Cells(21, 4).Value = rowData.HQ
            
            targetSheet.Cells(17, 7).Value = rowData.Employees
            targetSheet.Cells(18, 7).Value = rowData.LatestRaisedDate
            targetSheet.Cells(19, 7).Value = rowData.LatestRaised
            targetSheet.Cells(20, 7).Value = rowData.TotalRaised

        Else
            MsgBox "The sheet is protected and cannot be modified."
        End If
                
    Else
        MsgBox "Sheet does not exist."
    End If
End Sub

Sub ClearCoverPage(ws As Worksheet)
    ' Define the range to clear: Columns B through H starting from row 13 downwards
    ' Assuming the sheet might not be filled entirely to the last row of Excel, find the last used row in this range
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "H").End(xlUp).Row
    
    ' If the last used row is less than 13, there's nothing to clear
    If lastRow < 13 Then Exit Sub
    
    ' Clear contents of the range
    ws.range("B13:H" & lastRow).ClearContents
End Sub

Sub PopulateCover(coverSheet As Worksheet, companyInfoArr As Variant, NumCompanies As Long)
    Dim Row As Long
    Dim Col As Long
    Dim Half As Long
    
    Half = IIf(NumCompanies <= 20, 10, IIf(NumCompanies Mod 2 > 0, NumCompanies \ 2 + 1, NumCompanies \ 2))
    
    ' Clear cover range for testing
    ClearCoverPage coverSheet
        
    For i = 1 To NumCompanies
        If i <= Half Then
            Row = i + 12
            Col = 2
        Else
            Row = i - Half + 12
            Col = 6
        End If

        coverSheet.Cells(Row, Col).Value = i
        coverSheet.Cells(Row, Col + 1).Value = companyInfoArr(i, 1)
        coverSheet.Cells(Row, Col + 2).Value = companyInfoArr(i, 2)
    Next i

End Sub

Sub TakeScreenshot(range As Excel.range)
    ' Copy the range as an image
    On Error Resume Next ' Disable error reporting
    For i = 1 To 3 ' Attempt to copy up to three times
        range.CopyPicture Appearance:=xlScreen, Format:=xlPicture
        If Err.Number = 0 Then Exit For ' Exit loop if successful
        Err.Clear ' Clear the error
        Application.Wait Now + TimeValue("00:00:01") ' Wait for 1 second
    Next i
    On Error GoTo 0 ' Re-enable error reporting

End Sub

Sub AddSlideAndPaste(ppPres As PowerPoint.Presentation, Left As Integer, Top As Integer, Position As Integer)
    Dim ppSlide As Object
    Dim myShape As Object
    
    ' Add a new slide to the presentation at the end
    Set ppSlide = ppPres.Slides.Add(Position, 12) ' 12 corresponds to a blank slide
    
    ' Paste the image into the slide
    On Error Resume Next
    Application.Wait (Now + TimeValue("0:00:01")) ' Wait for 1 second
    ppSlide.Shapes.PasteSpecial DataType:=2 ' Trying paste operation
    If Err.Number <> 0 Then
        MsgBox "Failed to paste screenshot. Please try again.", vbCritical
    End If
    On Error GoTo 0
    
'    ppSlide.Shapes.PasteSpecial DataType:=2 ' 2 corresponds to pasting as a picture
    
    ' Optionally, adjust the position and size of the pasted image as needed
    Set myShape = ppSlide.Shapes(ppSlide.Shapes.Count)
    myShape.Left = Left
    myShape.Top = Top
End Sub

Sub ConsolidatedPowerPointExport(SheetName As String, ppPres As PowerPoint.Presentation, NumCompanies As Long, pptPath As String, Left As Integer, Top As Integer, Position As Integer)
    ' Define workbook
    Dim wb As Workbook
    Dim ws As Worksheet
    Set wb = ThisWorkbook
    Set ws = wb.Worksheets(SheetName)
    Dim rng As Excel.range
    Dim addString As String
    
    ws.Activate
    
    ' Determine range
    addString = IIf(SheetName = "Cover", IIf(NumCompanies <= 10, "D29", IIf(NumCompanies <= 20, "I29", "I" & (13 + NumCompanies \ 2))), "H29")
    Set rng = ws.range("A1:" & addString)
    
    TakeScreenshot rng
    AddSlideAndPaste ppPres, Left, Top, Position
    
    ppPres.SaveAs pptPath
    
End Sub

