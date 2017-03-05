Example of regex
==============================

{
  "collection": "user-info",
  "emailAddressList.emailAddress": {
    "$regex": {
      "$exp": "@bdemr"
    }
  }
}