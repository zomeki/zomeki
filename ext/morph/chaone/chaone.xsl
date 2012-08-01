<?xml version="1.0"?>

<!-- XSLT stylesheet for ChaOne              -->
<!--              for xalan, msxml and exslt -->
<!--                              ver. 1.3.2 -->
<!--                        for UniDic 1.3.* -->
<!-- ChaOne consists of the followings;      -->
<!--  (0) preprocessing                      -->
<!--  (1) ChaSen Chunker                     -->
<!--  (2) Phonetic Alternation               -->
<!--  (3) Accent Combination                 -->
<!--  (4) postprocessing for gtalk           -->
<!--                2008-02-12 by Studio ARC -->
<!-- Copyright (c) 2004-2008 Studio ARC      -->

<!-- This program is based on the product    -->
<!--   developed in IPA project 1999-2002    -->

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

  <xsl:import href="prep.xsl"/>
  <xsl:import href="chunker.xsl"/>
  <xsl:import href="phonetic.xsl"/>
  <xsl:import href="accent.xsl"/>
  <xsl:import href="postp.xsl"/>

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>

  <xsl:param name="standalone"/>
  <xsl:param name="debug"/>

  <xsl:variable name="ea_symbol_table" select="document('ea_symbol_table.xml')/cha:ea_symbol_table"/>
  <xsl:variable name="chunk_rules" select="document('chunk_rules.xml')/cha:chunk_rules"/>
  <xsl:variable name="IPA_table" select="document('IPAfn.xml')"/>
  <xsl:variable name="FPA_table" select="document('FPAfn.xml')"/>
  <xsl:key name="IPAfn" match="cha:ifn" use="concat(@iType, @iForm, @iConType)"/>
  <xsl:key name="FPAfn" match="cha:ffn" use="concat(@fType, @fForm, @fConType)"/>
  <xsl:variable name="ap_rule" select="document('ap_rule.xml')/cha:ap_rule/cha:rule"/>
  <xsl:variable name="accent_rule" select="document('accent_rule.xml')/cha:aType_rule/cha:rule"/>
  <xsl:variable name="kannjiyomi" select="document('kannjiyomi.xml')/cha:kannjiyomi/cha:char"/>
  <xsl:variable name="pos_sys" select="document('pos_sys.xml')"/>
  <xsl:key name="rpos" match="cha:pos" use="@name"/>
  <xsl:key name="rctype" match="cha:ctype" use="@name"/>
  <xsl:key name="rcform" match="cha:cform" use="@name"/>

  <xsl:template match="/">
    <xsl:if test="$debug">
      <xsl:message>
        <xsl:text>INPUT:&#x0A;</xsl:text>
        <xsl:apply-templates select="." mode="text"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="S | cha:S">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$standalone = 'prep'">
          <xsl:apply-templates mode="prep"/>
        </xsl:when>
        <xsl:when test="$standalone = 'chunker'">
          <xsl:apply-templates mode="chunker"/>
        </xsl:when>
        <xsl:when test="$standalone = 'phonetic'">
          <xsl:apply-templates mode="chaone"/>
        </xsl:when>
        <xsl:when test="$standalone = 'accent'">
          <xsl:variable name="ws">
            <xsl:apply-templates mode="preap"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="function-available('exsl:node-set')">
              <xsl:apply-templates select="exsl:node-set($ws)/*[1]" mode="mainap">
                <xsl:with-param name="stack" select="0"/>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="function-available('msxml:node-set')">
              <xsl:apply-templates select="msxml:node-set($ws)/*[1]" mode="mainap">
                <xsl:with-param name="stack" select="0"/>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="function-available('xalan:nodeset')">
              <xsl:apply-templates select="xalan:nodeset($ws)/*[1]" mode="mainap">
                <xsl:with-param name="stack" select="0"/>
              </xsl:apply-templates>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$standalone = 'postp'">
          <xsl:apply-templates mode="postp"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="preps">
            <cha:preps>
              <xsl:apply-templates mode="prep"/>
            </cha:preps>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="function-available('exsl:node-set')">
              <xsl:call-template name="preprocess">
                <xsl:with-param name="preps" select="exsl:node-set($preps)"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="function-available('msxml:node-set')">
              <xsl:call-template name="preprocess">
                <xsl:with-param name="preps" select="msxml:node-set($preps)"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="function-available('xalan:nodeset')">
              <xsl:call-template name="preprocess">
                <xsl:with-param name="preps" select="xalan:nodeset($preps)"/>
              </xsl:call-template>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="preprocess">
    <xsl:param name="preps"/>
    <xsl:if test="$debug">
      <xsl:message>
        <xsl:text>PreProcess:&#x0A;</xsl:text>
        <xsl:apply-templates select="$preps" mode="text"/>
      </xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$standalone = 'pc'">
        <xsl:apply-templates select="$preps/cha:preps/*" mode="chunker"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="chunk">
          <xsl:apply-templates select="$preps/cha:preps/*" mode="chunker"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="function-available('exsl:node-set')">
            <xsl:call-template name="chunker">
              <xsl:with-param name="chunk" select="exsl:node-set($chunk)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="function-available('msxml:node-set')">
            <xsl:call-template name="chunker">
              <xsl:with-param name="chunk" select="msxml:node-set($chunk)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="function-available('xalan:nodeset')">
            <xsl:call-template name="chunker">
              <xsl:with-param name="chunk" select="xalan:nodeset($chunk)"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="chunker">
    <xsl:param name="chunk"/>
    <xsl:if test="$debug">
      <xsl:message>
        <xsl:text>Chunker:&#x0A;</xsl:text>
        <xsl:apply-templates select="$chunk" mode="text"/>
      </xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="($standalone = 'pcp') or ($standalone = '')">
        <xsl:apply-templates select="$chunk/*" mode="chaone"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="pa">
          <xsl:apply-templates select="$chunk/*" mode="chaone"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="function-available('exsl:node-set')">
            <xsl:call-template name="phonetic">
              <xsl:with-param name="pa" select="exsl:node-set($pa)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="function-available('msxml:node-set')">
            <xsl:call-template name="phonetic">
              <xsl:with-param name="pa" select="msxml:node-set($pa)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="function-available('xalan:nodeset')">
            <xsl:call-template name="phonetic">
              <xsl:with-param name="pa" select="xalan:nodeset($pa)"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="phonetic">
    <xsl:param name="pa"/>
    <xsl:if test="$debug">
      <xsl:message>
        <xsl:text>Phonetic Alternation:&#x0A;</xsl:text>
        <xsl:apply-templates select="$pa" mode="text"/>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="ws">
      <xsl:apply-templates select="$pa/*" mode="preap"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="function-available('exsl:node-set')">
        <xsl:call-template name="accent">
          <xsl:with-param name="ws" select="exsl:node-set($ws)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="function-available('msxml:node-set')">
        <xsl:call-template name="accent">
          <xsl:with-param name="ws" select="msxml:node-set($ws)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="function-available('xalan:nodeset')">
        <xsl:call-template name="accent">
          <xsl:with-param name="ws" select="xalan:nodeset($ws)"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="accent">
    <xsl:param name="ws"/>
    <xsl:choose>
      <xsl:when test="$standalone = 'pcpa'">
        <xsl:apply-templates select="$ws/*[1]" mode="mainap">
          <xsl:with-param name="stack" select="0"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$standalone = 'gtalk'">
        <xsl:variable name="ap">
          <xsl:apply-templates select="$ws/*[1]" mode="mainap">
            <xsl:with-param name="stack" select="0"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="function-available('exsl:node-set')">
            <xsl:apply-templates select="exsl:node-set($ap)/*" mode="postp"/>
          </xsl:when>
          <xsl:when test="function-available('msxml:node-set')">
            <xsl:apply-templates select="msxml:node-set($ap)/*" mode="postp"/>
          </xsl:when>
          <xsl:when test="function-available('xalan:nodeset')">
            <xsl:apply-templates select="xalan:nodeset($ap)/*" mode="postp"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Unknown mode!</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="text">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:for-each select="@*">
      <xsl:value-of select="concat(' ', name(), '=&quot;', string(), '&quot;')"/>
    </xsl:for-each>
    <xsl:choose>
      <xsl:when test="*">
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates mode="text"/>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>/&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
