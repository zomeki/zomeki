<!-- XSLT stylesheet for ChaOne              -->
<!--              for xalan, msxml and exslt -->
<!--                            ver. 1.3.2   -->
<!--  (0) preprocessing                      -->
<!--                2008-02-12 by Studio ARC -->
<!-- Copyright (c) 2004-2008 Studio ARC      -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:msxml="urn:schemas-microsoft-com:xslt"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:cha="http://www.unidic.org/chasen/ns/structure/1.0" 
  xmlns:gtalk="http://www.astem.or.jp/istc/gtalk/ns/structure/1.0"
  extension-element-prefixes="exsl msxml xalan"
  exclude-result-prefixes="exsl msxml xalan gtalk"
  version="1.0"
  xml:lang="ja">

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>

  <xsl:param name="standalone"/>

  <xsl:variable name="ea_symbol_table" select="document('ea_symbol_table.xml')/cha:ea_symbol_table"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="/*[local-name() != 'S']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="S | cha:S">
    <cha:S>
      <xsl:apply-templates mode="prep"/>
    </cha:S>
  </xsl:template>

  <xsl:template match="W1 | cha:W1" mode="prep">
    <xsl:choose>
      <xsl:when test="($standalone = 'gtalk') and (@pos = '未知語')">
        <xsl:call-template name="ea-symbol-chk">
          <xsl:with-param name="orth" select="@orth"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <cha:W1>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="prep"/>
        </cha:W1>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="prep">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="W1len">
        <xsl:value-of select="count(descendant::W1 | descendant::cha:W1)"/>
      </xsl:attribute>
    </xsl:copy>
    <xsl:apply-templates mode="prep"/>
  </xsl:template>

  <xsl:template match="SILENCE|EMPH|SPELL|PRON|SPEECH|VOICE|RATE|VOLUME|PITCH|APB" mode="prep">
    <xsl:choose>
      <xsl:when test="$standalone = 'gtalk'">
        <xsl:choose>
          <xsl:when test="*">
            <xsl:element name="gtalk:{local-name()}">
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates mode="prep"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="gtalk:{local-name()}">
              <xsl:copy-of select="@*"/>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="W1len">
            <xsl:value-of select="count(descendant::W1 | descendant::cha:W1)"/>
          </xsl:attribute>
        </xsl:copy>
        <xsl:apply-templates mode="prep"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- preprocess for unknown pos with English Alphabet -->
  <xsl:template name="ea-symbol-chk">
    <xsl:param name="orth"/>
    <xsl:variable name="hits">
      <xsl:for-each select="$ea_symbol_table/cha:W1[starts-with($orth, @orth)]">
        <xsl:sort select="string-length(@orth)"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="function-available('exsl:node-set')">
        <xsl:call-template name="ea-symbol-chk-main">
          <xsl:with-param name="orth" select="$orth"/>
          <xsl:with-param name="hits" select="exsl:node-set($hits)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="function-available('msxml:node-set')">
        <xsl:call-template name="ea-symbol-chk-main">
          <xsl:with-param name="orth" select="$orth"/>
          <xsl:with-param name="hits" select="msxml:node-set($hits)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="function-available('xalan:nodeset')">
        <xsl:call-template name="ea-symbol-chk-main">
          <xsl:with-param name="orth" select="$orth"/>
          <xsl:with-param name="hits" select="xalan:nodeset($hits)"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ea-symbol-chk-main">
    <xsl:param name="orth"/>
    <xsl:param name="hits"/>
    <xsl:choose>
      <xsl:when test="$hits/cha:W1[1]/@orth">
        <xsl:apply-templates select="$hits/cha:W1[1]" mode="ea-symbol">
          <xsl:with-param name="orgW1" select="."/>
          <xsl:with-param name="orth" select="$orth"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:W1" mode="ea-symbol">
    <xsl:param name="orgW1"/>
    <xsl:param name="orth"/>
    <xsl:choose>
      <xsl:when test="@orth">
        <xsl:copy-of select="."/>
        <xsl:if test="string-length($orth) > string-length(@orth)">
          <!-- *** recursive call *** -->
          <xsl:call-template name="ea-symbol-chk">
            <xsl:with-param name="orth" select="substring($orth, string-length(@orth) + 1)"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$orgW1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
