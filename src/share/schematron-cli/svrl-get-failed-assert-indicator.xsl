<?xml version="1.0" encoding="UTF-8"?>
<stylesheet 
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns="http://www.w3.org/1999/XSL/Transform" 
  version="1.0">

  <output method="text"/>

  <template match="/">
    <choose>
      <when test="//svrl:failed-assert">
        <text>true&#10;</text>
      </when>
      <otherwise>
        <text>false&#10;</text>
      </otherwise>
    </choose>
  </template>

</stylesheet>
