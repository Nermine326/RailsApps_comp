<%Const ADMIN_DB_VER = "v1.3"%>

<HTML>
<HEAD>
	<TITLE>ADMIN_DB <%=ADMIN_DB_VER%></TITLE>
	<META NAME="LANGUAGE" CONTENT="FR">
	<META NAME="HTTP.LANGUAGE" CONTENT="FRENCH">
	<META NAME="AUTHOR" CONTENT="Nermine Hamdi">
	
</HEAD>

<SCRIPT LANGUAGE=VBScript RUNAT=Server>
	

	Function ObjInput(sType, sName, sValue, sTitle, sLen)
		Dim rtn
		
		IF IsNull(sValue) Then sValue = Space(1)
		
		'Remplace les guillemets par des espaces
		If Not IsNull(sValue) Then sValue = Replace(sValue, Chr(34), Chr(32))
		
		rtn = "<Input Type=" & sType & " Name=" & sName & " " & _
			"Value=" & Chr(34) & sValue & Chr(34) & " Title=" & Chr(34) & sTitle & Chr(34) & " "

		Select Case sType
		
			Case "Text"
			
				rtn = rtn & "maxlength=" & sLen & " "
				rtn = rtn & "Size=" & sLen & " "
			
			Case "Submit"

				rtn = rtn & " " & _
					"ONMOUSEOUT=" & Chr(34) & "this.className = 'Btn';"  & Chr(34) & " " & _
					"ONMOUSEDOWN=" & Chr(34) & "this.className = 'btnDown';"  & Chr(34) & " " & _
					"ONMOUSEUP=" & Chr(34) & "this.className = 'btnOver';"  & Chr(34) & " " & _
					"ONMOUSEOVER=" & Chr(34) & "this.className = 'btnOver';"  & Chr(34) & " " 
		End Select

		rtn = rtn & ">"
	
		ObjInput = rtn
	End Function
	
	Function ObjInputChk(sName, sValue)
		Dim rtn
		
		rtn = "<Input Type=CheckBox Name=" & sName & " "
		select case sValue
			Case "O", "Y", -1
				rtn = rtn & "Checked"
		End select
				
		rtn = rtn & " >"
		ObjInputChk = rtn
	End Function
	
	Function ObjTextArea(sName, sValue, nCol, nRow)
		Dim rtn
		
		rtn = "<TextArea Name=" & sName & " Cols=" & nCol & " Rows=" & nRow & _
			">"
		rtn = rtn & sValue
		rtn = rtn & "</TextArea>"
		ObjTextArea = rtn
	End Function	
	
	' === Fonction pour la BDD ===
	
	Function CboSchemaTable(sName, sSize, sType)
		Dim rstSchema
		Dim buff
		
		Set rstSchema = Session("conn").OpenSchema(20)
		
		buff = "<SELECT NAME=" & sName & " STYLE='width:" & sSize & "px'>"
		Do Until rstSchema.EOF
			
			If(UCase(rstSchema("TABLE_TYPE")) = sType) Then
				buff = buff & "<OPTION value=" & rstSchema("TABLE_NAME") & ">" & rstSchema("TABLE_NAME") & "</OPTION>"
			End If
			
			rstSchema.MoveNext
		Loop
				
		rstSchema.Close
		Set rstSchema = nothing
		
		buff = buff & "</SELECT>"

   		CboSchemaTable = buff   		
	End Function

	Function OpenConnexion(cnx, sUID, sPWD)
		On Error Resume Next
		
		Session("conn").open cnx
		
		if(err.number <> 0) then
			Session("ERR_MSG") = Err.Number & "<br>" & Err.Description
			OpenConnexion = False
		Else
			OpenConnexion = True
		End If
	End Function
	
	Function ConnectDB(C_Connect)
		On Error Resume Next
		
		Set Session("conn") = Server.CreateObject("ADODB.Connection")
		If(err.number <> 0) then
			Session("ERR_MSG") = Err.Number & "<br>" & Err.Description
			Exit Function
		End If
		
		Session("conn").CommandTimeout = 300
		
		ConnectDB = OpenConnexion(C_Connect, "", "")
			
	End Function

	Function DoubleQuote(s)
		
		DoubleQuote = Replace(s, "'", "''")
			
	End Function
	
	' *** Fonction de compatcge de la bdd
	Function CompactDB()

		' Fermeture de la bdd
		Session("conn").close
		Set Session("conn") = nothing

		nameBaseSource = Session("DB")
		pathBaseSource = Server.MapPath(".")
		uidBaseSource = Session("USER_NAME")
		pwdBaseSource = Session("USER_PWD")
		MDWSource = Session("MDW")
		pathDataBaseSource = pathBaseSource & nameBaseSource
		pathMDWSource = pathBaseSource & MDWSource
		
		' Définition de la base compactée temporaire
		nameBaseDestination = Session("DB") & "_compact.mdb"
		pathBaseDestination = Server.MapPath(".")
		pathDataBaseDestination = pathBaseDestination & nameBaseDestination
		
		' Définition des valeurs du compactage
		strProvider = "Provider=Microsoft.Jet.OLEDB.4.0;"
		strEngine = "Jet OLEDB:Engine Type=5;"
		strEncrypt = "Jet OLEDB:Encrypt Database=True;" 
		
		strDataBaseSource = "Data Source=" & pathDataBaseSource & ";"
		strDataBaseDestination = "Data Source=" & pathDataBaseDestination & ";"
		
		If(Len(Session("MDW")) > 0) Then
			strUidBaseSource = "User ID=" & uidBaseSource & ";"
			strPwdBaseSource = "Password=" & pwdBaseSource & ";"
			strMDWBaseSource = "Jet OLEDB:System Database=" & pathMDWSource & ";"

			strUidBaseDestination = "User ID=" & uidBaseSource & ";"
			strPwdBaseDestination = "Password=" & pwdBaseSource & ";"
			strMDWBaseSource = "Jet OLEDB:System Database=" & pathMDWSource & ";"
			
			strCompactDataBaseSource = strProvider & strDataBaseSource & strUidBaseSource & strPwdBaseSource & strMDWBaseSource
			strCompactDataBaseDestination = strProvider & strEngine & strEncrypt & strDataBaseDestination & strMDWBaseSource
		ElseIf(Len(Session("PWD")) > 0) Then
			strPwdBaseSource = "Jet OLEDB:Database Password=" & pwdBaseSource & ";"

			strPwdBaseDestination = "Jet OLEDB:Database Password=" & pwdBaseSource & ";"
			
			strCompactDataBaseSource = strProvider & strDataBaseSource & strPwdBaseSource
			strCompactDataBaseDestination = strProvider & strEngine & strEncrypt & strDataBaseDestination & strPwdBaseSource
		Else
			strCompactDataBaseSource = strProvider & strDataBaseSource
			strCompactDataBaseDestination = strProvider & strEngine & strEncrypt & strDataBaseDestination
		End If
		
		' Création d'un objet FileSystemObject
		Set ObjFileSystem = Server.CreateObject("Scripting.FileSystemObject")
		
		' Vérification de l'existence de la base à compacter
		If (ObjFileSystem.FileExists(pathDataBaseSource)) Then
		
		     ' Vérifie que la base temporaire n'existe pas
		     If (ObjFileSystem.FileExists(pathDataBaseDestination)) Then
		        'Si elle existe la base temporaire est effacée
		        ObjFileSystem.DeleteFile pathDataBaseDestination
		     End If
		
		     ' Création de l'objet JetEngine
		     Set ObjEngine = Server.CreateObject("JRO.JetEngine")
		     ' Compactage de la base de données
		     ObjEngine.CompactDatabase strCompactDataBaseSource, strCompactDataBaseDestination
		     ' Destruction de l'objet JetEngine
		     Set ObjEngine = Nothing
		
		     ' Remplacement de l'ancienne base par la base compactée temporaire
		     ObjFileSystem.CopyFile pathDataBaseDestination,pathDataBaseSource ,True
		     ' Effacement de la base compactée temporaire
		     ObjFileSystem.DeleteFile pathDataBaseDestination
		
		End If
		
		' Destruction de l'objet FileSystemObject
		Set ObjFileSystem = Nothing
	
		' Réouverture de la bdd
		response.redirect "admin_db.asp?Action=1"
		
	End Function
	' ***
	
</SCRIPT>

<BODY>

<h1 align="center"><u><b>Administration de base de donnée à distance<br>Microsoft ACCESS</b></u></h1>
<p>&nbsp;</p>

<%
Dim strTMP
Dim bcl, rs, nRow, nRowPos
Dim menu
Dim FieldNB
Dim FieldsName(), FieldsValue()

' Menu
menu = "<p><a href='admin_db.asp?Action=50'>Déconnexion de la base</a>"
menu = menu & "<br>"
menu = menu & "<ul>"
menu = menu & "<li><a href='admin_db.asp?Action=10'>Ouvrir une table/vue</a></li>"
menu = menu & "<li><a href='admin_db.asp?Action=20'>Exécuter une requête de sélection SQL</a></li>"
menu = menu & "<li><a href='admin_db.asp?Action=30'>Exécuter une requête SQL</a></li>"
menu = menu & "<li><a href='admin_db.asp?Action=60'>Propriétés de la base de donnée</a></li>"
menu = menu & "<li><a href='admin_db.asp?Action=90'>Compacter la base de donnée</a></li>"
menu = menu & "</ul></p>"
menu = menu & "<p>&nbsp;</p>"
menu = menu & "<center>"


' Retour sur page de connect si saut indirect
If(Len(Trim(Session("DB"))) < 1 and (request.querystring("Action") <> 1 and request.querystring("Action") <> 2)) Then
	response.redirect "admin_db.asp?Action=1"
End If

' Affichage du message d'erreur
If(Len(Trim(Session("ERR_MSG"))) > 0) Then
	response.write "<p align=center><b><font color=red>Erreur : " & Session("ERR_MSG") & "</font></b></p>"
	Session("ERR_MSG") = ""
End If

' === Page HTML ===
Select Case request.querystring("Action")

	Case 1 ' Initialisation
		Session("conn") = ""
		Set Session("rs") = Nothing

		Session("TB") = ""
		Session("DB") = ""
		Session("USER_NAME") = ""
		Session("USER_PWD") = ""
		Session("MDW") = ""
		Session("READ_ONLY") = ""
		Session("IS_TABLE") = False
		
		response.write "<center>"
		response.write "<FORM action=admin_db.asp?Action=2 method=POST id=f_menu name=f_form Target='_self'>"
		response.write "<table border=1 cellspacing=0 cellpadding=0>"
		response.write "<tr>"
		response.write "<td bgcolor=red colspan=2 align=center><font color=white><b>CONNEXION</b></font></td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td bgcolor=orange align=left><b>Nom de la base de donnée</b></td>"
		response.write "<td bgcolor=orange align=left>" & ObjInput("Text", "DB", "", "", 40) & "</td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td align=left><b>Fichier de sécurité (.MDW)</b></td>"
		response.write "<td align=left>" & ObjInput("Text", "MDW", "", "", 40) & "</td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td align=left><b>Nom d'utilisateur</b></td>"
		response.write "<td align=left>" & ObjInput("Text", "USER_NAME", "", "", 40) & "</td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td align=left><b>Mot de passe</b></td>"
		response.write "<td align=left>" & ObjInput("Password", "USER_PWD", "", "", 40) & "</td>"
		response.write "</tr>"
		response.write "<tr bgcolor=red>"
		response.write "<td colspan=2 align=center><INPUT TYPE=submit Name=Btn_ok value=Connexion></td>"
		response.write "</table>"
		response.write "</form>"
		response.write "</center>"
		
		
	Case 2 ' Connexion
		If(Trim(request.form("DB")) = "") Then
			Session("ERR_MSG") = "Le champ 'Nom de la base de donnée' doit être obligatoirement renseigné."
			response.redirect "admin_db.asp?Action=1"
		ElseIf((Trim(request.form("MDW")) <> "") and (Trim(request.form("USER_NAME")) ="" or Trim(request.form("USER_PWD")) = "")) Then
			Session("ERR_MSG") = "Les champs 'Nom d'utilisateur' et 'Mot de passe' doivent être renseignés si le champ 'Fichier de sécurité (.MDW)' est renseigné."
			response.redirect "admin_db.asp?Action=1"
		Else
			Session("DB") = Trim(request.form("DB"))
			Session("MDW") = Trim(request.form("MDW"))
			Session("USER_NAME") = Trim(request.form("USER_NAME"))
			Session("USER_PWD") = Trim(request.form("USER_PWD"))
		End If
		
		strTMP = "DRIVER={Microsoft Access Driver (*.mdb)};DBQ=" & Server.MapPath(".") & Session("DB")
		If(Len(Session("MDW")) > 0) Then
			strTMP = strTMP & ";SYSTEMDB=" & Server.MapPath(".") & Session("MDW")
			strTMP = strTMP & ";UID=" & Session("USER_NAME")
		End If
		
		If(Len(Session("USER_PWD")) > 0) Then
			strTMP = strTMP & ";PWD=" & Session("USER_PWD")
		End If
		
		If(ConnectDB(strTMP) = True) Then
			response.redirect "admin_db.asp?Action=3"
		Else
			response.redirect "admin_db.asp?Action=1"
		End If
		
	
	Case 3 ' Menu de connexion
		response.write menu

		
	Case 10 ' Sélection d'une table
		Session("TB") = ""
		Session("READ_ONLY") = ""
		
		response.write menu

		response.write "<FORM action=admin_db.asp?Action=11&IsTable=1 method=POST id=f_menu name=f_form Target='_self'>"
		response.write "<table border=1 cellspacing=0 cellpadding=0>"
		response.write "<tr>"
		response.write "<td bgcolor=red colspan=2 align=center><font color=white><b>OUVRIR UNE TABLE</b></font></td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td align=left><b>Nom de la table</b></td>"
		response.write "<td align=center>" & CboSchemaTable("TB",220, "TABLE") & "</td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td colspan=2 align=center>Ouvrir en lecture seule (chargement plus rapide) ?" & ObjInputChk("READ_ONLY", -1) & "</td>"
		response.write "</tr>"
		response.write "<tr bgcolor=red>"
		response.write "<td colspan=2 align=center><INPUT TYPE=submit Name=Btn_ok value=Ouvrir></td>"
		response.write "</table>"
		response.write "</form>"

		response.write "<FORM action=admin_db.asp?Action=11&IsTable=0 method=POST id=f_menu name=f_form Target='_self'>"
		response.write "<table border=1 cellspacing=0 cellpadding=0>"
		response.write "<tr>"
		response.write "<td bgcolor=red colspan=2 align=center><font color=white><b>OUVRIR UNE VUE</b></font></td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td align=left><b>Nom de la vue</b></td>"
		response.write "<td align=center>" & CboSchemaTable("TB",220, "VIEW") & "</td>"
		response.write "</tr>"
		response.write "<tr bgcolor=red>"
		response.write "<td colspan=2 align=center><INPUT TYPE=submit Name=Btn_ok value=Ouvrir></td>"
		response.write "</table>"
		response.write "</form>"
		response.write "</center>"
	
	
	Case 11 ' Ouverture de la table
		On Error Resume Next
		
		If(request.querystring("IsTable") = 1) Then
			Session("IS_TABLE") = True
		Else
			If(Len(Trim(request.querystring("IsTable"))) > 0 And request.querystring("IsTable") = 0) Then
				Session("IS_TABLE") = False
			End If
		End If
		
		If(request.querystring("Retour") <> 1) Then
			If(Session("TB") <> "") Then
				Session("rs").Close
				Set Session("rs") = nothing
			End If
			
			Session("TB") = UCase(Trim(request.form("TB")))
			
			If(Session("READ_ONLY") = "") Then
				Session("READ_ONLY") = request.form("READ_ONLY")
			End If
		End If
				
		response.write menu
		
		
		Set Session("rs") = Server.CreateObject("ADODB.Recordset")
		Session("rs").Open Session("TB"), Session("conn"), 3, 3, 2
		If(err.number<>0) Then
			Session("ERR_MSG") = Err.Number & "<br>" & Err.Description
			response.redirect "admin_db.asp?Action=3"
		End If
				
		
		response.write "<p><u><b>Consultation de la table/vue : " & Session("TB") & "</b></u></p>"
		
		response.write "<table border=1 cellspacing=0 cellpadding=0>"

		response.write "<tr>"			
		For bcl = 0 To Session("rs").Fields.Count - 1
			response.write "<td bgcolor=red align=center><b><a href='admin_db.asp?Action=80&FieldNB=" & bcl & "'>" & Session("rs").Fields(bcl).Name & "</a></b></td>"
		Next
		If not (Len(Trim(Session("READ_ONLY"))) > 0 Or Session("IS_TABLE") = False) Then
			response.write "<td bgcolor=red align=center>&nbsp;</td>"
		End If
		response.write "</tr>"

		If not Session("rs").eof Then
			
			nRowPos = 0
			
			Do until Session("rs").eof
				
				response.write "<FORM action=admin_db.asp?Action=12 method=POST id=f_menu name=f_form Target='_self'>"
				response.write "<tr>"

				response.write "<input type=hidden name=ID value=" & nRowPos & ">"
				
				For Each fldLoop In Session("rs").Fields
				
					If(Len(Trim(Session("READ_ONLY"))) > 0 Or Session("IS_TABLE") = False) Then
						response.write "<td align=center>&nbsp;" & fldLoop.Value & "</td>"
					Else
						Select Case fldLoop.Attributes
							Case 20 ' Booléen
								response.write "<td align=center>" & ObjInputChk(fldLoop.Name, fldLoop) & "</td>"
								
							Case 230 ' Memo
								response.write "<td align=center>" & ObjTextArea(fldLoop.Name, fldLoop.Value, 50, 3) & "</td>"

							Case Else
								response.write "<td align=center>" & ObjInput("Text", fldLoop.Name, fldLoop.Value, "", fldLoop.DefinedSize) & "</td>"
								
						End Select
					End If
				Next
			
				Session("rs").movenext

				If not (Len(Trim(Session("READ_ONLY"))) > 0 Or Session("IS_TABLE") = False) Then
					response.write "<td align=center><input type=submit name=Btn_Suppr value=Supprimer>&nbsp;<input type=submit name=Btn_Mod value=Modifier></td>"
				End If
				response.write "</tr>"
				response.write "</FORM>"
				
				nRowPos = nRowPos + 1
				
			loop
		
		Else
			If not (Len(Trim(Session("READ_ONLY"))) > 0 Or Session("IS_TABLE") = False) Then
				response.write "<td align=center colspan=" & Session("rs").Fields.Count + 1 & "><b>La table " & Session("TB") & " n'a renvoyée aucun résultat</b></td>"
			Else
				response.write "<td align=center colspan=" & Session("rs").Fields.Count & "><b>La table " & Session("TB") & " n'a renvoyée aucun résultat</b></td>"
			End If
		End If

		If not (Len(Trim(Session("READ_ONLY"))) > 0 Or Session("IS_TABLE") = False) Then
			response.write "<tr bgcolor=orange><td align=center colspan=" & Session("rs").Fields.Count + 1 & "><b>Ajout</b></td></tr>"
			
			response.write "<FORM action=admin_db.asp?Action=13 method=POST id=f_menu name=f_form Target='_self'>"
			response.write "<tr>"
			
			For bcl = 0 to Session("rs").Fields.Count -1
				Select Case Session("rs").Fields(bcl).Attributes
					Case 20 ' Booléen
						response.write "<td align=center>" & ObjInputChk(Session("rs").Fields(bcl).Name, 0) & "</td>"
						
					Case 230 ' Memo
						response.write "<td align=center>" & ObjTextArea(Session("rs").Fields(bcl).Name, "", 50, 3) & "</td>"

					Case Else
						response.write "<td align=center>" & ObjInput("Text", Session("rs").Fields(bcl).Name, "", "", Session("rs").Fields(bcl).DefinedSize) & "</td>"
						
				End Select				
			Next

			If not Session("rs").eof Then
				response.write "<td colspan=2 align=center><input type=submit name=Btn_Add value=Ajouter></td>"
			Else
				response.write "<td align=center><input type=submit name=Btn_Add value=Ajouter></td>"
			End If
			response.write "</tr>"
			response.write "</FORM>"
		End If

		response.write "</table>"

		response.write "<p><a href='admin_db.asp?Action=70'>Propriétés de la table/vue '" & Session("TB") & "'</a></p>"

		response.write "</center>"
	
	
	Case 12 ' Suppression/modif d'un record
		On Error Resume Next

		Session("rs").MoveFirst
		Session("rs").Move CLng(request.form("ID"))
		
		If(err.number<>0) Then
			Session("ERR_MSG") = Err.Number & "<br>" & Err.Description
			response.redirect "admin_db.asp?Action=3"
		End If

		If(Len(Trim(request.form("Btn_Suppr"))) > 0) Then
			Session("rs").Delete
			If(err.number<>0) Then
				Session("ERR_MSG") = Err.Number & "<br>" & Err.Description
				response.redirect "admin_db.asp?Action=3"
			End If
		ElseIf(Len(Trim(request.form("Btn_Mod"))) > 0) Then
			For bcl=0 to Session("rs").Fields.Count - 1
                                'response.write Session("rs").Fields(bcl).Name  & " " & Session("rs").Fields(bcl).Attributes & " " & Session("rs").Fields(bcl).Type & "<br>"
				Select Case Session("rs").Fields(bcl).Attributes
					Case 16 ' Numéro auto
					Case 116 ' Numérique + Date
						If(Session("rs").Fields(bcl).Type = 135) Then ' Date
							Session("rs").Fields(bcl) = CDate(request.form(Session("rs").Fields(bcl).Name))
							Session("rs").Update							
						Else
							Session("rs").Fields(bcl) = CLng(request.form(Session("rs").Fields(bcl).Name))
							Session("rs").Update
						End If
					Case 20 ' Booléen
						Session("rs").Fields(bcl) = CBool((Len(Trim(request.form(Session("rs").Fields(bcl).Name))) > 1))
						Session("rs").Update
					Case Else
						Session("rs").Fields(bcl) = request.form(Session("rs").Fields(bcl).Name)
						Session("rs").Update
				End Select
			Next
		End If
		
		response.redirect "admin_db.asp?Action=11&Retour=1"
		
	
	Case 13 ' Ajout d'un record
		On Error Resume Next
		
		Session("rs").AddNew
			For bcl=0 to Session("rs").Fields.Count - 1
				Select Case Session("rs").Fields(bcl).Attributes
					Case 16 ' Numéro auto
					Case 116 ' Numérique + Date
						If(Session("rs").Fields(bcl).Type = 135) Then ' Date
							Session("rs").Fields(bcl) = CDate(request.form(Session("rs").Fields(bcl).Name))
						Else
							Session("rs").Fields(bcl) = CLng(request.form(Session("rs").Fields(bcl).Name))
						End If
					Case 20 ' Booléen
						Session("rs").Fields(bcl) = CBool((Len(Trim(request.form(Session("rs").Fields(bcl).Name))) > 1))
					Case Else
						Session("rs").Fields(bcl) = request.form(Session("rs").Fields(bcl).Name)
				End Select
			Next
		Session("rs").Update

		response.redirect "admin_db.asp?Action=11&Retour=1"

		
	Case 20 ' Ordre SQL (de sélection)
		Session("TB") = ""
		
		response.write menu
		
		response.write "<FORM action=admin_db.asp?Action=21 method=POST id=f_menu name=f_form Target='_self'>"
		response.write "<table border=1 cellspacing=0 cellpadding=0>"
		response.write "<tr>"
		response.write "<td bgcolor=red colspan=2 align=center><font color=white><b>EXECUTER UN ORDRE SQL DE SELECTION</b></font></td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td align=left><b>Ordre SQL</b></td>"
		response.write "<td align=center>" & ObjTextArea("SQL", "", 80, 3) & "</td>"
		response.write "</tr>"
		response.write "<tr bgcolor=red>"
		response.write "<td colspan=2 align=center><INPUT TYPE=submit Name=Btn_ok value=Execution></td>"
		response.write "</table>"
		response.write "</form>"
		response.write "</center>"


	Case 21 ' Execution d'un ordre SQL (de sélection)
		On Error Resume Next
		
		If(Session("TB") <> "") Then
			Session("rs").Close
			Set Session("rs") = nothing
		End If

		Session("TB") = UCase(Trim(request.form("SQL")))
				
		response.write menu
		
		SQL = Trim(request.form("SQL"))
		
		Set Session("rs") = Server.CreateObject("ADODB.Recordset")
		Session("rs").Open SQL, Session("conn")
		
		If(err.number<>0) Then
			Session("ERR_MSG") = Err.Number & "<br>" & Err.Description
			response.redirect "admin_db.asp?Action=3"
		End If
		
		If not Session("rs").eof Then
		
			response.write "<p><u><b>Execution de l'ordre SQL : " & SQL & "</b></u></p>"
			
			response.write "<table border=1 cellspacing=0 cellpadding=0>"

			response.write "<tr>"
			For bcl=0 To Session("rs").Fields.Count -1
				response.write "<td bgcolor=orange align=center><b>" & Session("rs").Fields(bcl).Name & "</b></td>"
			Next
			response.write "</tr>"
			
			Do until Session("rs").eof

				response.write "<tr>"

				For bcl=0 To Session("rs").Fields.Count -1				
					response.write "<td align=center>&nbsp;" & Session("rs").Fields(bcl) & "</td>"
				Next
			
				Session("rs").movenext

				response.write "</tr>"

			loop
			
			response.write "</table>"
		Else
			response.write "<p align=center><b>L'ordre SQL '" & SQL & "' n'a renvoyé aucun résultat</b></p>"
		End If
		
		response.write "</center>"
	

	Case 30 ' Ordre SQL
		response.write menu
		
		response.write "<FORM action=admin_db.asp?Action=31 method=POST id=f_menu name=f_form Target='_self'>"
		response.write "<table border=1 cellspacing=0 cellpadding=0>"
		response.write "<tr>"
		response.write "<td bgcolor=red colspan=2 align=center><font color=white><b>EXECUTER UN ORDRE SQL</b></font></td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td align=left><b>Ordre SQL</b></td>"
		response.write "<td align=center>" & ObjTextArea("SQL", "", 80, 3) & "</td>"
		response.write "</tr>"
		response.write "<tr bgcolor=red>"
		response.write "<td colspan=2 align=center><INPUT TYPE=submit Name=Btn_ok value=Execution></td>"
		response.write "</table>"
		response.write "</form>"
		response.write "</center>"


	Case 31 ' Execution d'un ordre SQL	
		On Error Resume Next

		If(Session("TB") <> "") Then
			Session("rs").Close
			Set Session("rs") = nothing
		End If

		'Session("TB") = UCase(Trim(request.form("SQL")))
		
		response.write menu
		
		SQL = Trim(request.form("SQL"))
		
		Session("conn").Execute SQL, nRow
		If(err.number<>0) Then
			Session("ERR_MSG") = Err.Number & "<br>" & Err.Description
			response.redirect "admin_db.asp?Action=3"
		ElseIf nRow=0 Then
			Session("ERR_MSG") = "Erreur lors de l'éxecution de l'ordre SQL"
			response.redirect "admin_db.asp?Action=3"
		End If
		
		response.write "</center>"
		

	Case 50 ' Déconnexion de la base
		On Error Resume Next
		
		Session("DB") = ""
		Session("USER_NAME") = ""
		Session("USER_PWD") = ""
		Session("MDW") = ""
		Session("READ_ONLY") = ""
		
		If(Session("TB") <> "") Then
			Session("rs").Close
			Set Session("rs") = nothing
		End If
		
		Session("conn").close
		Set Session("conn") = nothing
	
		response.redirect "admin_db.asp?Action=1"


	Case 60 ' Information sur la base
		On Error Resume Next
		
		response.write menu
		
		response.write "<table border=1 cellspacing=0 cellpadding=0>"
		response.write "<tr>"
		response.write "<td bgcolor=red colspan=2 align=center><font color=white><b>PROPRIETES DE LA BASE DE DONNEE</b></font></td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td bgcolor=orange align=left><b>Propriété</b></td>"
		response.write "<td bgcolor=orange align=left><b>Valeur</b></td>"
		response.write "</tr>"
		
		For bcl=0 To Session("conn").properties.count -1
			response.write "<tr>"
			response.write "<td align=left>&nbsp;" & Session("conn").properties(bcl).Name & "</td>"
			response.write "<td align=left>&nbsp;" & Session("conn").properties(bcl).Value & "</td>"
			response.write "</tr>"
		Next

		response.write "</table>"
		response.write "</center>"
		

	Case 70 ' Information sur la table
		On Error Resume Next
		
		response.write menu
		
		response.write "<table border=1 cellspacing=0 cellpadding=0>"
		response.write "<tr>"
		response.write "<td bgcolor=red colspan=2 align=center><font color=white><b>PROPRIETES DE LA TABLE/VUE '" & Session("TB") & "'</b></font></td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td bgcolor=orange align=left><b>Propriété</b></td>"
		response.write "<td bgcolor=orange align=left><b>Valeur</b></td>"
		response.write "</tr>"
		
		For bcl=0 To Session("rs").properties.count -1
			response.write "<tr>"
			response.write "<td align=left>&nbsp;" & Session("rs").properties(bcl).Name & "</td>"
			response.write "<td align=left>&nbsp;" & Session("rs").properties(bcl).Value & "</td>"
			response.write "</tr>"
		Next

		response.write "</table>"
		
		response.write "<p><a href='admin_db.asp?Action=11&Retour=1'>Retour à la table/vue '" & Session("TB") & "'</a></p>"		
		
		response.write "</center>"


	Case 80 ' Information sur le champ
		On Error Resume Next
		
		FieldNB = CInt(request.querystring("FieldNB"))
		
		response.write menu
		
		response.write "<table border=1 cellspacing=0 cellpadding=0>"
		response.write "<tr>"
		response.write "<td bgcolor=red colspan=2 align=center><font color=white><b>PROPRIETES DU CHAMP '" & Session("rs").Fields(FieldNB).Name & "' DE LA TABLE/VUE '" & Session("TB") & "'</b></font></td>"
		response.write "</tr>"
		response.write "<tr>"
		response.write "<td bgcolor=orange align=left><b>Propriété</b></td>"
		response.write "<td bgcolor=orange align=left><b>Valeur</b></td>"
		response.write "</tr>"
		
		For bcl=0 To Session("rs").Fields(FieldNB).properties.count -1
			response.write "<tr>"
			response.write "<td align=left>&nbsp;" & Session("rs").Fields(FieldNB).properties(bcl).Name & "</td>"
			response.write "<td align=left>&nbsp;"
			response.write Session("rs").Fields(FieldNB).properties(bcl).Value
			response.write "</td>"
			response.write "</tr>"
		Next

		response.write "</table>"
		
		response.write "<p><a href='admin_db.asp?Action=11&Retour=1'>Retour à la table/vue '" & Session("TB") & "'</a></p>"		
		
		response.write "</center>"

	Case 90 ' Compactage de la bdd
		
		Call CompactDB()

	Case Else
		response.redirect "admin_db.asp?Action=1"
		
End Select

response.write "<h5 align=right>"
response.write "Admin DB " & ADMIN_DB_VER & "<br>"
response.write "<a href='mailto:jdprog@wanadoo.fr?subject=A propos de admin_db' title='jdprog@wanadoo.fr'><i>Jérôme DUPUY</i></a>"
If(Len(Trim(Session("DB"))) > 0) Then
	response.write "<br><br>Provider : " & Session("conn").Provider
	response.write "<br>ADO Version : " & Session("conn").Version & "<br>"
End If
response.write "</h5>"
%>

</BODY>
</HTML>