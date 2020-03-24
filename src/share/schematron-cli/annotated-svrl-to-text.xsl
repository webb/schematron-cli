<?xml version="1.0" encoding="US-ASCII"?>
<stylesheet 
  version="1.0"
  xmlns:ann="https://github.com/webb/schematron-cli/ns/svrl-annotation"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns="http://www.w3.org/1999/XSL/Transform">

  <output method="text"/>

  <param name="filename"/>

  <template match="svrl:successful-report | svrl:failed-assert">
    <variable name="pattern" select="preceding-sibling::svrl:active-pattern[1]"/>
    <value-of select="concat($filename, ':', @ann:line-number, ':', local-name(), ':', $pattern/@id, ':', $pattern/@name)"/>
    <if test="svrl:text">
      <text>:</text>
      <value-of select="normalize-space(svrl:text)"/>
    </if>
    <text>&#10;</text>
  </template>

  <template match="text()"/>

</stylesheet>
