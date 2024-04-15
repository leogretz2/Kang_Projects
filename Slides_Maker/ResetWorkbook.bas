Attribute VB_Name = "ResetWorkbook"

Sub ResetWorkbook()
    ' Display a message box with Yes and No buttons
    response = MsgBox("Do you want to reset everything? Yes will reset the workbook back to one blank cover page, empty data table and one 'Main' company page. No will reset the workbook back to one blank cover page, and one 'Main' company page, but will leave the 'Data' sheet untouched. Cancel will exit this dialogue.", vbYesNoCancel + vbQuestion, "Clearing Options")

    ' Check the user's response
    If response = vbCancel Then
        MsgBox "User chose to exit.", vbInformation, "Exiting"
        Exit Sub ' Exit the subroutine if the user responds with No
    End If

    Dim ws As Worksheet
    Dim i As Integer

    ' Loop through each worksheet in the workbook
    For i = ThisWorkbook.Worksheets.Count To 1 Step -1
        Set ws = ThisWorkbook.Worksheets(i)
        
        If ws.Name = "Main" Or ws.Name = "Data2" Then
            ' TODO: remove Data2 expemption
            ' TODO: Fix Upgraded By (also capitalization)
            ' Skip these sheets
            ' Continue For
        ElseIf ws.Name Like "Cover*" Then
            If ws.Name <> "Cover" Then
                ' Delete any additional Cover pages
                Application.DisplayAlerts = False ' Turn off alerts to suppress the confirmation dialog
                ws.Delete
                Application.DisplayAlerts = True  ' Turn alerts back on
            Else
                Dim lastRowColOne As Long
                lastRowColOne = ws.Cells(ws.Rows.Count, "B").End(xlUp).Row
            
                ' If the last used row is less than 13, there's nothing to clear
                If lastRowColOne >= 13 Then
                    ' Clear contents of the range
                    ws.range("B13:H" & lastRowColOne).ClearContents
                End If
            End If
            
        ElseIf ws.Name = "Data" Then
            If response = vbYes Then
                ' Determine the last row with content in each worksheet
                lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
        
                ' Leave headers untouched:
                If lastRow > 1 Then
                    ws.range("A2:Z" & lastRow).Delete Shift:=xlUp
                End If
            End If
            
        Else
            ' Delete the worksheet that doesn't match any of the above conditions
            Application.DisplayAlerts = False ' Turn off alerts to suppress the confirmation dialog
            ws.Delete
            Application.DisplayAlerts = True  ' Turn alerts back on
        End If
    Next i
    
    If response = vbYes Then
        MsgBox "All sheets have been reset."
    ElseIf response = vbNo Then
        MsgBox "All sheets besides Data have been reset."
    End If
    
End Sub

' TODO: add stop current macro button?
