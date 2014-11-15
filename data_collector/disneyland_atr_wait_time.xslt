<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes" indent="no" />

  <xsl:strip-space elements="*"/>

  <!-- 日付値 -->
  <xsl:param name="datetime" />

  <xsl:template match="text()" />

  <xsl:template match="h2[@class='themeName']">
    <xsl:text>@</xsl:text><xsl:value-of select="." /><xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- すべての<a>をマッチする -->
  <xsl:template match="a">
    <!-- aの子供として、div[@class='about']があれば、処理する -->
    <xsl:if test="div[@class='about']">
      <!-- 日付 -->
      <xsl:value-of select="$datetime" />
      <xsl:text>,</xsl:text>
      <!-- 名称、稼働状況、ファストパス -->
      <xsl:apply-templates select="div[@class='about']" />
      <xsl:text>,</xsl:text>
      <!-- 待ち時間 -->
      <xsl:apply-templates select="div[@class='time']" />
      <xsl:text>,</xsl:text>
      <!-- 更新時刻 -->
      <xsl:apply-templates select="p[@class='update']" />
      <!-- 改行 -->
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="div[@class='about']">
    <!-- 名称 -->
    <xsl:value-of select="h3/text()" />
    <xsl:text>,</xsl:text>
    <!-- 稼働状況 -->
    <xsl:value-of select="normalize-space(p[@class='run']/text())" />
    <xsl:text>,</xsl:text>
    <!-- ファストパス -->
    <!-- ファストパスがある場合はfp、ない場合はfp-no -->
    <xsl:if test="p[@class='fp']">
      <!-- "発券中(&nbsp;"と")"を削除する -->
      <xsl:variable name="fp" select="translate(translate(p[@class='fp'],'発券中(&#160;',''),')','')" />
      <xsl:value-of select="$fp" />
    </xsl:if>
    <xsl:if test="p[@class='fp-no']">
      <xsl:value-of select="p[@class='fp-no']" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="p[@class='update']">
    <xsl:variable name="update" select="translate(translate(text(),'(更新時間：',''),')','')" />
    <xsl:value-of select="$update" />
  </xsl:template>

  <xsl:template match="div[@class='time']">
    <xsl:value-of select="translate(p[@class='waitTime'],'分','')" />
  </xsl:template>
</xsl:stylesheet>
