<?xml version="1.0" encoding="UTF-8"?>
<stylesheet 
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/XSL/Transform">

  <output method="text"/>

  <template match="/">
    <choose>
      <when test="/xsl:stylesheet/@version">
        <value-of select="/xsl:stylesheet/@version"/>
      </when>
      <when test="/xsl:stylesheet">
        <value-of select="1.0"/>
      </when>
      <when test="/*/@xsl:version">
        <value-of select="/*/@xsl:version"/>
      </when>
      <otherwise>
        <text>unknown</text>
      </otherwise>
    </choose>
  </template>

</stylesheet>
