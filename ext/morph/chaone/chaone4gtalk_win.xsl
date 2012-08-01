<!-- XSLT stylesheet for ChaOne               -->
<!--   stylesheet loader for gtalk (win)      -->
<!--                      for msxml and exslt -->
<!--                               ver. 1.3.2 -->
<!--                 2008-02-12 by Studio ARC -->
<!-- Copyright (c) 2004-2008 Studio ARC       -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cha="http://www.unidic.org/chasen/ns/structure/1.0" 
  xmlns:gtalk="http://www.astem.or.jp/istc/gtalk/ns/structure/1.0"
  exclude-result-prefixes="gtalk"
  version="1.0"
  xml:lang="ja">

  <xsl:import href="chaone.xsl"/>
  <xsl:variable name="encoding" select="'Shift_JIS'"/>
  <xsl:output method="xml" encoding="Shift_JIS" omit-xml-declaration="yes" indent="yes"/>
  <xsl:param name="standalone" select="'gtalk'"/>

</xsl:stylesheet>
