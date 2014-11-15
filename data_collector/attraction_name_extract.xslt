<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes" indent="no" />

  <xsl:strip-space elements="*"/>

  <xsl:template match="text()" />

  <xsl:template match="h2[@class='themeName']">
    <xsl:variable name="header"><xsl:value-of select="."/></xsl:variable>
    <xsl:for-each select="following-sibling::*">
      <xsl:if test="a/div[@class='about']/h3">
        <xsl:value-of select="$header" />
        <xsl:text>,</xsl:text>
        <xsl:value-of select="a/div[@class='about']/h3" />
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!--
  <xsl:template name="attractions" match="a">
    <xsl:param name="land" />
    <xsl:if test="div[@class='about']/h3">
      <xsl:value-of select="$land" />
      <xsl:text>,</xsl:text>
      <xsl:value-of select="div[@class='about']/h3" />
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>
  -->

</xsl:stylesheet>
