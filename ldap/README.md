# XNAT External LDAP Service #

This includes [users.ldif], which has ten users represented in three separate domains:

* `ou=accounts,dc=xnatworks,dc=io` uses email addresses with first and last name separated by `.` for UIDs: `Alice.Smith@xnatworks.io`
* `ou=users,dc=xnatworks,dc=io` uses first initial and last name for UIDs: `asmith`
* `ou=auth,dc=xnatworks,dc=io` uses first name and last name separated by `_` for UIDs: `Alice_Smith`

