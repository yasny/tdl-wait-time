<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes" indent="no" />

  <xsl:strip-space elements="*"/>

  <xsl:template match="text()" />

  <xsl:template match="a">
    <xsl:if test="div[@class='about']/h3">
      <xsl:value-of select="div[@class='about']/h3" />
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
