Attribute VB_Name = "Automated_Macro"

Sub FormatCopyAutomated()

    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Data")
    
    Dim lastRow As Long
    Dim i As Long
    
    ' Find the last row of the table
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).row
    
    For i = 2 To lastRow ' Assuming row 1 has headers
        Dim rowData As New CompanyData
        RowToNewSheet ws, i, rowData
                
    Next i
    
    MsgBox "Done"
    
    ' TODO: Handle cover page
    
End Sub

Sub RowToNewSheet(Worksheet, row, rowData)
    
    ' Construct CompanyData
    Dim rowData As New CompanyData
    ConstructCompanyData Worksheet, row, rowData
    
    ' Create a new sheet or get the existing one and assign it to a Worksheet variable
    Dim newSheet As Worksheet
    Set newSheet = CreateNewSheet(rowData.CompanyName)
    
    ' Assign values to new Sheet
'    SimpleCell newSheet, rowData
    AssignValuesToSheet newSheet, rowData
    
    'Export Sheet to Powerpoint
     ExportRangeToPowerPoint rowData.CompanyName
    
        
End Sub

Sub ConstructCompanyData(ws, i, rowData)

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
        .LatestRaisedDate = ws.Cells(i, 31).Value 'Column AE
        .LatestRaised = ws.Cells(i, 32).Value 'Column AF
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
            
            targetSheet.Cells(17, 4).Value = rowData.CompanyOwner & " " & rowData.Team
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

Sub ExportRangeToPowerPoint(SheetName As String)

    ' Define workbook
    Dim wb As Workbook
    Dim ws As Worksheet
    Set wb = ThisWorkbook
    Set ws = wb.Worksheets(SheetName)
    ws.Activate
    
    ' Define the range you want to copy
    Dim rng As Excel.Range
    Set rng = ws.Range("A1:H29")
    
    ' Copy the range as an image
    rng.CopyPicture Appearance:=xlScreen, Format:=xlPicture

    ' Start a new instance of PowerPoint
    Dim ppApp As Object
    Dim ppPres As Object
    Dim ppSlide As Object

    ' Create a new PowerPoint application
    Set ppApp = CreateObject("PowerPoint.Application")
    ppApp.Visible = True ' Make PowerPoint visible

    ' Add a new presentation
    Set ppPres = ppApp.Presentations.Add

    ' Add a new slide to the presentation
    Set ppSlide = ppPres.Slides.Add(1, 12) ' 12 corresponds to a blank slide

    ' Paste the image into the slide
    ppSlide.Shapes.PasteSpecial DataType:=2 ' 2 corresponds to pasting as a picture
    
    ' Optionally, you can adjust the position and size of the pasted image as needed
    Dim myShape As Object
    Set myShape = ppSlide.Shapes(ppSlide.Shapes.Count)
    ' myShape.Left = 50
    myShape.Top = 50
    
    ' Save the PowerPoint presentation
    Dim pptPath As String
    pptPath = ThisWorkbook.Path & "\" & SheetName & "_Presentation.pptx"
    ppPres.SaveAs pptPath
    ppApp.Quit

    ' Clean up
    Set rng = Nothing
    Set ppSlide = Nothing
    Set ppPres = Nothing
    Set ppApp = Nothing

End Sub

Sub SimpleCell(targetSheet, rowData)
'    Dim targetSheet As Worksheet
'    Set targetSheet = ThisWorkbook.Sheets("HeroDevs")
    
'    ThisWorkbook.Sheets("Main").Copy Before:=ThisWorkbook.Sheets(2)
'    Set targetSheet = ActiveSheet
    
'    Application.ScreenUpdating = True
'    Application.EnableEvents = False
    
    If Not targetSheet.ProtectionMode Then
            targetSheet.Cells(2, 3).Value = rowData.CompanyName
            
        Else
            MsgBox "The sheet is protected - change the setting for the macro to work."
        End If

'    Application.Calculation = xlCalculationManual
'    With targetSheet
'        .Cells(3, 2).Value = "BEKF"
'        ' Ensure this is the only place you're setting the cell value
'    End With
'    Application.EnableEvents = True
'    Application.Calculation = xlCalculationAutomatic
    
End Sub
