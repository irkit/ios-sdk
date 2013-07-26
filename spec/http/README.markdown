HTTP API Docs
===

Host: getirkit.appspot.com

POST /apps/one/icons
---

Create Icon with image data and ir signal data.

### Request parameters ###

* icon

    multipart/form-data jpeg or png binary

* irdata

    IR data

* irfreq

    IR carrier frequency in KHz.
    Optional, default: 38.

### Response JSON ###

```
{
  icon: {
    id: "xxxxxx",
    url: "xxxxxxx"
  }
}
```

GET /apps/one/icons/{icon.id}
---

Redirect to data scheme which user bookmarks

### Path parameters ###

- icon.id

    id retrieved by POST /apps/one/icons
