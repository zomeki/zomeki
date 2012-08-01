<!-- XSLT stylesheet for ChaOne              -->
<!--              for xalan, msxml and exslt -->
<!--  (3) Accent Combination                 -->
<!--                              ver. 1.3.2 -->
<!--                        for UniDic 1.3.* -->
<!--                2008-02-12 by Studio ARC -->
<!-- Copyright (c) 2004-2008 Studio ARC      -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cha="http://www.unidic.org/chasen/ns/structure/1.0"
  xmlns:gtalk="http://www.astem.or.jp/istc/gtalk/ns/structure/1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns:msxml="urn:schemas-microsoft-com:xslt"
  xmlns:xalan="http://xml.apache.org/xalan"
  extension-element-prefixes="exsl msxml xalan"
  exclude-result-prefixes="exsl msxml xalan gtalk"
  version="1.0"
  xml:lang="ja">

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>

  <xsl:param name="standalone"/>

  <xsl:variable name="ap_rule" select="document('ap_rule.xml')/cha:ap_rule/cha:rule"/>
  <xsl:variable name="accent_rule" select="document('accent_rule.xml')/cha:aType_rule/cha:rule"/>
  <xsl:variable name="kannjiyomi" select="document('kannjiyomi.xml')/cha:kannjiyomi/cha:char"/>

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="*">
    <xsl:choose>
      <xsl:when test="*">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:S">
    <xsl:variable name="ws">
      <xsl:apply-templates mode="preap"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
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
    </xsl:copy>
  </xsl:template>

  <xsl:template match="cha:W1 | cha:W2 | gtalk:PRON" mode="preap">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="*" mode="preap">
    <xsl:choose>
      <xsl:when test="child::*">
        <xsl:variable name="num" select="generate-id()"/>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="start">
            <xsl:value-of select="$num"/>
          </xsl:attribute>
        </xsl:copy>
        <xsl:apply-templates mode="preap"/>
        <xsl:copy>
          <xsl:attribute name="end">
            <xsl:value-of select="$num"/>
          </xsl:attribute>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="preap">
  </xsl:template>

  <xsl:template match="*" mode="mainap">
    <xsl:param name="stack"/>
    <xsl:param name="pre"/>
    <xsl:choose>
      <xsl:when test="following-sibling::*[1]">
        <xsl:apply-templates select="following-sibling::*[1]" mode="mainap">
          <xsl:with-param name="stack" select="$stack + 1"/>
          <xsl:with-param name="pre" select="$pre"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="ap_terminate">
          <xsl:with-param name="term" select="'after'"/>
          <xsl:with-param name="stack" select="$stack + 1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="mainap">
  </xsl:template>

  <xsl:template match="gtalk:SILENCE | gtalk:APB" mode="mainap">
    <xsl:param name="stack"/>
    <xsl:param name="pre"/>
    <xsl:if test="$stack > 0">
      <xsl:call-template name="ap_terminate">
        <xsl:with-param name="term" select="'before'"/>
        <xsl:with-param name="stack" select="$stack"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="ap_terminate">
      <xsl:with-param name="term" select="'after'"/>
      <xsl:with-param name="stack" select="1"/>
    </xsl:call-template>
    <xsl:call-template name="process_following_or_not">
      <xsl:with-param name="stack" select="0"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="cha:W1 | cha:W2 | gtalk:PRON" mode="mainap">
    <xsl:param name="stack"/>
    <xsl:param name="pre"/>
    <xsl:variable name="next" select="following-sibling::*[(local-name() = 'W1') or (local-name() = 'W2') or (local-name() = 'PRON')][1]"/>
    <xsl:variable name="term">
      <xsl:choose>
        <xsl:when test="following-sibling::*[1][local-name() = 'APB']">
          <xsl:value-of select="'new'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="chk_ap_rule">
            <xsl:with-param name="current" select="."/>
            <xsl:with-param name="pre" select="$pre"/>
            <xsl:with-param name="next" select="$next"/>
            <xsl:with-param name="nth" select="'0'"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$term = 'cont'">
        <xsl:call-template name="process_following_or_not">
          <xsl:with-param name="stack" select="$stack + 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$stack > 0">
          <xsl:call-template name="ap_terminate">
            <xsl:with-param name="term" select="'before'"/>
            <xsl:with-param name="stack" select="$stack"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$term = 'new'">
            <xsl:call-template name="process_following_or_not">
              <xsl:with-param name="stack" select="1"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$term = 'alone'">
            <xsl:call-template name="ap_terminate">
              <xsl:with-param name="term" select="'after'"/>
              <xsl:with-param name="stack" select="1"/>
            </xsl:call-template>
            <xsl:call-template name="process_following_or_not">
              <xsl:with-param name="stack" select="0"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>NOT CORRECT!</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="chk_ap_rule">
    <xsl:param name="current"/>
    <xsl:param name="pre"/>
    <xsl:param name="next"/>
    <xsl:param name="nth"/>
    <xsl:variable name="result">
      <xsl:call-template name="chk_ap_rule_one">
        <xsl:with-param name="current" select="$current"/>
        <xsl:with-param name="pre" select="$pre"/>
        <xsl:with-param name="next" select="$next"/>
        <xsl:with-param name="rule" select="$ap_rule[$nth]"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$result != ''">
        <xsl:value-of select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="chk_ap_rule">
          <xsl:with-param name="current" select="$current"/>
          <xsl:with-param name="pre" select="$pre"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="nth" select="$nth + 1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="chk_ap_rule_one">
    <xsl:param name="current"/>
    <xsl:param name="pre"/>
    <xsl:param name="next"/>
    <xsl:param name="rule"/>
    <xsl:variable name="result">
      <xsl:call-template name="chk_ap_rule_one_cond">
        <xsl:with-param name="current" select="$current"/>
        <xsl:with-param name="pre" select="$pre"/>
        <xsl:with-param name="next" select="$next"/>
        <xsl:with-param name="cond" select="$rule/cha:cond"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$result = 'true'">
      <xsl:value-of select="$rule/cha:then/@ap"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="chk_ap_rule_one_cond">
    <xsl:param name="current"/>
    <xsl:param name="pre"/>
    <xsl:param name="next"/>
    <xsl:param name="cond"/>
    <xsl:apply-templates select="$cond/*" mode="chkap">
      <xsl:with-param name="current" select="$current"/>
      <xsl:with-param name="pre" select="$pre"/>
      <xsl:with-param name="next" select="$next"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="cha:current" mode="chkap">
    <xsl:param name="current"/>
    <xsl:param name="pre"/>
    <xsl:param name="next"/>
    <xsl:variable name="attr" select="name(@*)"/>
    <xsl:variable name="val" select="@*[name() = $attr]"/>
    <xsl:choose>
      <xsl:when test="starts-with($current/@*[name() = $attr], $val)">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:pre" mode="chkap">
    <xsl:param name="current"/>
    <xsl:param name="pre"/>
    <xsl:param name="next"/>
    <xsl:variable name="attr" select="name(@*)"/>
    <xsl:variable name="val" select="@*[name() = $attr]"/>
    <xsl:variable name="prechk">
      <xsl:choose>
        <xsl:when test="function-available('exsl:node-set')">
          <xsl:value-of select="exsl:node-set($pre)/@*[name() = $attr]"/>
        </xsl:when>
        <xsl:when test="function-available('msxml:node-set')">
          <xsl:value-of select="msxml:node-set($pre)/@*[name() = $attr]"/>
        </xsl:when>
        <xsl:when test="function-available('xalan:nodeset')">
          <xsl:value-of select="xalan:nodeset($pre)/@*[name() = $attr]"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$pre and starts-with($prechk, $val)">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:next" mode="chkap">
    <xsl:param name="current"/>
    <xsl:param name="pre"/>
    <xsl:param name="next"/>
    <xsl:variable name="attr" select="name(@*)"/>
    <xsl:variable name="val" select="@*[name() = $attr]"/>
    <xsl:choose>
      <xsl:when test="starts-with($next/@*[name() = $attr], $val)">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:or" mode="chkap">
    <xsl:param name="current"/>
    <xsl:param name="pre"/>
    <xsl:param name="next"/>
    <xsl:variable name="result">
      <xsl:apply-templates select="*" mode="chkap">
        <xsl:with-param name="current" select="$current"/>
        <xsl:with-param name="pre" select="$pre"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($result, 'true')">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:and" mode="chkap">
    <xsl:param name="current"/>
    <xsl:param name="pre"/>
    <xsl:param name="next"/>
    <xsl:variable name="result">
      <xsl:apply-templates select="*" mode="chkap">
        <xsl:with-param name="current" select="$current"/>
        <xsl:with-param name="pre" select="$pre"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($result, 'false')">
        <xsl:text>false</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>true</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:not" mode="chkap">
    <xsl:param name="current"/>
    <xsl:param name="pre"/>
    <xsl:param name="next"/>
    <xsl:variable name="result">
      <xsl:apply-templates select="*" mode="chkap">
        <xsl:with-param name="current" select="$current"/>
        <xsl:with-param name="pre" select="$pre"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($result, 'true')">
        <xsl:text>false</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>true</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:default" mode="chkap">
    <xsl:param name="current"/>
    <xsl:param name="pre"/>
    <xsl:param name="next"/>
    <xsl:text>true</xsl:text>
  </xsl:template>

  <xsl:template name="process_following_or_not">
    <xsl:param name="stack"/>
    <xsl:choose>
      <xsl:when test="following-sibling::*">
        <xsl:apply-templates select="following-sibling::*[1]" mode="mainap">
          <xsl:with-param name="stack" select="$stack"/>
          <xsl:with-param name="pre" select="."/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$stack > 0">
          <xsl:call-template name="ap_terminate">
            <xsl:with-param name="term" select="'after'"/>
            <xsl:with-param name="stack" select="$stack"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ap_terminate">
    <xsl:param name="term"/>
    <xsl:param name="stack"/>
    <xsl:variable name="aps">
      <xsl:call-template name="mkap">
        <xsl:with-param name="term" select="$term"/>
        <xsl:with-param name="stack" select="$stack"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="function-available('exsl:node-set')">
        <xsl:call-template name="ap_terminate_main">
          <xsl:with-param name="term" select="$term"/>
          <xsl:with-param name="ap" select="exsl:node-set($aps)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="function-available('msxml:node-set')">
        <xsl:call-template name="ap_terminate_main">
          <xsl:with-param name="term" select="$term"/>
          <xsl:with-param name="ap" select="msxml:node-set($aps)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="function-available('xalan:nodeset')">
        <xsl:call-template name="ap_terminate_main">
          <xsl:with-param name="term" select="$term"/>
          <xsl:with-param name="ap" select="xalan:nodeset($aps)"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ap_terminate_main">
    <xsl:param name="term"/>
    <xsl:param name="ap"/>
    <cha:AP>
      <xsl:attribute name="orth">
        <xsl:for-each select="$ap/*">
          <xsl:value-of select="@orth"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="pron">
        <xsl:for-each select="$ap/*">
          <xsl:value-of select="@pron"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="aType">
        <xsl:call-template name="calc-atype">
          <xsl:with-param name="ws" select="$ap/*[(local-name() = 'W1') or (local-name() = 'W2') or (local-name() = 'PRON')]"/>
          <xsl:with-param name="preatype">
            <xsl:call-template name="get-substring-before">
              <xsl:with-param name="string" select="$ap/*[1]/@aType"/>
              <xsl:with-param name="delim" select="','"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="prepron" select="$ap/*[1]/@pron"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="silence">
        <xsl:variable name="spos" select="$ap/*[1]/@pos"/>
        <xsl:choose>
          <xsl:when test="($spos = '補助記号-読点') or ($spos = '補助記号-括弧開') or ($spos = '補助記号-括弧閉') or ((self::gtalk:SILENCE)
and ($term = 'after'))">PAU</xsl:when>
          <xsl:when test="$spos = '補助記号-句点'">SILE</xsl:when>
          <xsl:otherwise>NON</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="($term = 'before') and (@orth = '？')">
        <xsl:attribute name="interrogative">YES</xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="$ap"/>
    </cha:AP>
  </xsl:template>

  <xsl:template name="mkap">
    <xsl:param name="term"/>
    <xsl:param name="stack"/>
    <xsl:call-template name="mkap_sub">
      <xsl:with-param name="term" select="$term"/>
      <xsl:with-param name="npre">
        <xsl:choose>
          <xsl:when test="$term = 'before'">
            <xsl:value-of select="$stack"/>
          </xsl:when>
          <xsl:when test="$term = 'after'">
            <xsl:value-of select="$stack - 1"/>
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="preW"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="mkap_sub">
    <xsl:param name="term"/>
    <xsl:param name="npre"/>
    <xsl:param name="preW"/>
    <xsl:choose>
      <xsl:when test="$npre > 0">
        <xsl:variable name="curW">
          <xsl:apply-templates select="preceding-sibling::*[position() = $npre]" mode="apac"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="function-available('exsl:node-set')">
            <xsl:copy-of select="exsl:node-set($curW)"/>
          </xsl:when>
          <xsl:when test="function-available('msxml:node-set')">
            <xsl:copy-of select="msxml:node-set($curW)"/>
          </xsl:when>
          <xsl:when test="function-available('xalan:nodeset')">
            <xsl:copy-of select="xalan:nodeset($curW)"/>
          </xsl:when>
        </xsl:choose>
        <xsl:call-template name="mkap_sub">
          <xsl:with-param name="term" select="$term"/>
          <xsl:with-param name="npre" select="$npre - 1"/>
          <xsl:with-param name="preW" select="$curW"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="($npre = 0) and ($term = 'after')">
        <xsl:variable name="curW">
          <xsl:apply-templates select="." mode="apac"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="function-available('exsl:node-set')">
            <xsl:copy-of select="exsl:node-set($curW)"/>
          </xsl:when>
          <xsl:when test="function-available('msxml:node-set')">
            <xsl:copy-of select="msxml:node-set($curW)"/>
          </xsl:when>
          <xsl:when test="function-available('xalan:nodeset')">
            <xsl:copy-of select="xalan:nodeset($curW)"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise -->
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="apac">
    <xsl:choose>
      <xsl:when test="*">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="apac"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="apac">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="cha:W1" mode="apac">
    <xsl:choose>
      <xsl:when test="@pos='未知語'">
        <xsl:copy>
          <xsl:copy-of select="@*[name() != 'pron']"/>
          <xsl:attribute name="pron">
            <xsl:choose>
              <xsl:when test="($standalone = 'gtalk') and ($kannjiyomi/@orth = @orth)">
                <xsl:value-of select="$kannjiyomi[@orth = current()/@orth]/@pron"/>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="aType">1</xsl:attribute>
          <xsl:attribute name="aConType">C4</xsl:attribute>
          <xsl:apply-templates mode="apac"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*[name() != 'aType']"/>
          <xsl:attribute name="aType">
            <xsl:call-template name="calc-mod-aType">
              <xsl:with-param name="aType">
                <xsl:call-template name="get-substring-before">
                  <xsl:with-param name="string" select="@aType"/>
                  <xsl:with-param name="delim" select="','"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="len">
                <xsl:call-template name="calc-mora">
                  <xsl:with-param name="pron" select="@pron"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="aModType" select="@aModType"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates mode="apac"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-mod-aType">
    <xsl:param name="aType"/>
    <xsl:param name="len"/>
    <xsl:param name="aModType"/>
    <xsl:choose>
      <xsl:when test="$aModType">
        <xsl:variable name="type" select="substring-before($aModType, '@')"/>
        <xsl:variable name="val" select="substring-after($aModType, '@')"/>
        <xsl:choose>
          <xsl:when test="$type = 'M1'">
            <xsl:value-of select="$len - $val"/>
          </xsl:when>
          <xsl:when test="($type = 'M2') and ($aType = 0)">
            <xsl:value-of select="$len - $val"/>
          </xsl:when>
          <xsl:when test="($type = 'M3') and ($aType > 0)">
            <xsl:value-of select="$len - $val"/>
          </xsl:when>
          <xsl:when test="($type = 'M4') and ($aType > 1)">
            <xsl:value-of select="$aType - $val"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$aType"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$aType"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:W2[@pos = '未知語']" mode="apac">
    <xsl:copy>
      <xsl:copy-of select="@*[name() != 'pron']"/>
      <xsl:if test="not(string(@aType))">
        <xsl:attribute name="aType">
          <xsl:text>0</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="pron">
        <xsl:choose>
          <xsl:when test="($standalone = 'gtalk') and ($kannjiyomi/@orth = @orth)">
            <xsl:value-of select="$kannjiyomi[@orth = current()/@orth]/@pron"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="cha:W1/@pron"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:copy-of select="*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="cha:W2" mode="apac">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="ddts">
        <xsl:apply-templates mode="apac"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="function-available('exsl:node-set')">
          <xsl:call-template name="apac4W2">
            <xsl:with-param name="ddt" select="exsl:node-set($ddts)"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="function-available('msxml:node-set')">
          <xsl:call-template name="apac4W2">
            <xsl:with-param name="ddt" select="msxml:node-set($ddts)"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="function-available('xalan:nodeset')">
          <xsl:call-template name="apac4W2">
            <xsl:with-param name="ddt" select="xalan:nodeset($ddts)"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="apac4W2">
    <xsl:param name="ddt"/>
    <xsl:if test="not(string(@aType))">
      <xsl:attribute name="aType">
        <xsl:call-template name="calc-atype">
          <xsl:with-param name="ws" select="$ddt/cha:W1"/>
          <xsl:with-param name="preatype">
            <xsl:call-template name="get-substring-before">
              <xsl:with-param name="string" select="$ddt/*[1]/@aType"/>
              <xsl:with-param name="delim" select="','"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="prepron" select="$ddt/cha:W1[1]/@pron"/>
        </xsl:call-template>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="not(string(@aConType))">
      <xsl:attribute name="aConType">
        <xsl:value-of select="$ddt/cha:W1[1]/@aConType"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="not(string(@pron))">
      <xsl:attribute name="pron">
        <xsl:value-of select="$ddt/cha:W1/@pron"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$ddt"/>
  </xsl:template>

  <xsl:template match="gtalk:PRON" mode="apac">
    <xsl:copy>
      <xsl:copy-of select="@*[name() != 'POS']"/>
      <xsl:variable name="ddts">
        <xsl:apply-templates mode="apac"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="function-available('exsl:node-set')">
          <xsl:call-template name="apac4PRON">
            <xsl:with-param name="ddt" select="exsl:node-set($ddts)"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="function-available('msxml:node-set')">
          <xsl:call-template name="apac4PRON">
            <xsl:with-param name="ddt" select="msxml:node-set($ddts)"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="function-available('xalan:nodeset')">
          <xsl:call-template name="apac4PRON">
            <xsl:with-param name="ddt" select="xalan:nodeset($ddts)"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="apac4PRON">
    <xsl:param name="ddt"/>
    <xsl:if test="not(string(@orth))">
      <xsl:attribute name="orth">
        <xsl:for-each select="$ddt/*/@orth">
          <xsl:value-of select="."/>
        </xsl:for-each>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="not(string(@pron))">
      <xsl:attribute name="pron">
        <xsl:value-of select="translate(@SYM, '’', '')"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="string(@POS)">
        <xsl:attribute name="pos">
          <xsl:value-of select="@POS"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not(string(@pos))">
          <xsl:attribute name="pos">
            <xsl:value-of select="$ddt/*[position() = last()]/@pos"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="not(string(@aType))">
      <xsl:attribute name="aType">
        <xsl:call-template name="calc-mora">
          <xsl:with-param name="pron" select="substring-before(@SYM, '’')"/>
        </xsl:call-template>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="not(string(@aConType))">
      <xsl:if test="$ddt/*[position() = last()]/@aConType">
        <xsl:attribute name="aConType">
          <xsl:value-of select="$ddt/*[position() = last()]/@aConType"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:if>
    <xsl:copy-of select="$ddt"/>
  </xsl:template>

  <xsl:template name="calc-atype">
    <xsl:param name="ws"/>
    <xsl:param name="preatype"/>
    <xsl:param name="prepron"/>
    <xsl:choose>
      <xsl:when test="$ws[2]">
        <xsl:variable name="atype">
          <xsl:call-template name="calc-atype-pairwise">
            <xsl:with-param name="preatype" select="$preatype"/>
            <xsl:with-param name="prepron" select="$prepron"/>
            <xsl:with-param name="pre" select="$ws[1]"/>
            <xsl:with-param name="current" select="$ws[2]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$ws[3]">
            <xsl:call-template name="calc-atype">
              <xsl:with-param name="ws" select="$ws[position() != 1]"/>
              <xsl:with-param name="preatype" select="$atype"/>
              <xsl:with-param name="prepron" select="concat($prepron, $ws[2]/@pron)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$atype"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$ws[1]/@aType">
        <xsl:call-template name="get-substring-before">
          <xsl:with-param name="string" select="$ws[1]/@aType"/>
          <xsl:with-param name="delim" select="','"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-atype-pairwise">
    <xsl:param name="preatype"/>
    <xsl:param name="prepron"/>
    <xsl:param name="pre"/>
    <xsl:param name="current"/>
    <xsl:call-template name="apply-atype-rule">
      <xsl:with-param name="preatype" select="$preatype"/>
      <xsl:with-param name="prepron" select="$prepron"/>
      <xsl:with-param name="pre" select="$pre"/>
      <xsl:with-param name="current" select="$current"/>
      <xsl:with-param name="atype-rule">
        <xsl:call-template name="select-atype-rule">
          <xsl:with-param name="pre" select="$pre"/>
          <xsl:with-param name="current" select="$current"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="select-atype-rule">
    <xsl:param name="pre"/>
    <xsl:param name="current"/>
    <xsl:choose>
      <xsl:when test="contains($pre/@aConType, 'P')">
        <xsl:call-template name="select-atype-rule-sub">
          <xsl:with-param name="aConType" select="$pre/@aConType"/>
          <xsl:with-param name="pos" select="$current/@pos"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($current/@aConType, 'F')">
        <xsl:call-template name="select-atype-rule-sub">
          <xsl:with-param name="aConType" select="$current/@aConType"/>
          <xsl:with-param name="pos" select="$pre/@pos"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($current/@aConType, 'C')">
        <xsl:call-template name="select-atype-rule-sub">
          <xsl:with-param name="aConType" select="$current/@aConType"/>
          <xsl:with-param name="pos" select="$pre/@pos"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>default</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="select-atype-rule-sub">
    <xsl:param name="aConType"/>
    <xsl:param name="pos"/>
    <xsl:choose>
      <xsl:when test="contains($aConType, '%')">
        <xsl:variable name="phead">
          <xsl:choose>
            <xsl:when test="contains($pos, '-')">
              <xsl:value-of select="substring-before($pos, '-')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$pos"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>%</xsl:text>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($aConType, $phead)">
            <xsl:value-of select="substring-after($aConType, $phead)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring-after($aConType, '%')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$aConType"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="apply-atype-rule">
    <xsl:param name="preatype"/>
    <xsl:param name="prepron"/>
    <xsl:param name="pre"/>
    <xsl:param name="current"/>
    <xsl:param name="atype-rule"/>
    <xsl:variable name="head">
      <xsl:call-template name="get-substring-before">
        <xsl:with-param name="string" select="$atype-rule"/>
        <xsl:with-param name="delim" select="','"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="rule-id">
      <xsl:call-template name="get-substring-before">
        <xsl:with-param name="string" select="$head"/>
        <xsl:with-param name="delim" select="'@'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="cm">
      <xsl:choose>
        <xsl:when test="contains($head, '@')">
          <xsl:value-of select="substring-after($head, '@')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="get-substring-before">
            <xsl:with-param name="string" select="$current/@aType"/>
            <xsl:with-param name="delim" select="','"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cm2">
      <xsl:choose>
        <xsl:when test="($rule-id = 'F6') or ($rule-id = 'F9')">
          <xsl:call-template name="get-substring-before">
            <xsl:with-param name="string" select="substring-after($atype-rule, ',')"/>
            <xsl:with-param name="delim" select="','"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates select="$accent_rule[@id = $rule-id]/cha:then" mode="apatype">
      <xsl:with-param name="preatype" select="$preatype"/>
      <xsl:with-param name="prepron" select="$prepron"/>
      <xsl:with-param name="pre" select="$pre"/>
      <xsl:with-param name="current" select="$current"/>
      <xsl:with-param name="cm" select="$cm"/>
      <xsl:with-param name="cm2" select="$cm2"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="get-substring-before">
    <xsl:param name="string"/>
    <xsl:param name="delim"/>
    <xsl:choose>
      <xsl:when test="contains($string, $delim)">
        <xsl:value-of select="substring-before($string, $delim)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:then | cha:else" mode="apatype">
    <xsl:param name="preatype"/>
    <xsl:param name="prepron"/>
    <xsl:param name="pre"/>
    <xsl:param name="current"/>
    <xsl:param name="cm"/>
    <xsl:param name="cm2"/>
    <xsl:choose>
      <xsl:when test="@aType">
        <xsl:call-template name="calc-atype-val">
          <xsl:with-param name="exp" select="@aType"/>
          <xsl:with-param name="preatype" select="$preatype"/>
          <xsl:with-param name="prepron" select="$prepron"/>
          <xsl:with-param name="pre" select="$pre"/>
          <xsl:with-param name="current" select="$current"/>
          <xsl:with-param name="cm" select="$cm"/>
          <xsl:with-param name="cm2" select="$cm2"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="flg">
          <xsl:apply-templates select="cha:if/*" mode="apatype">
            <xsl:with-param name="preatype" select="$preatype"/>
            <xsl:with-param name="prepron" select="$prepron"/>
            <xsl:with-param name="pre" select="$pre"/>
            <xsl:with-param name="current" select="$current"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$flg = 'yes'">
            <xsl:apply-templates select="cha:then" mode="apatype">
              <xsl:with-param name="preatype" select="$preatype"/>
              <xsl:with-param name="prepron" select="$prepron"/>
              <xsl:with-param name="pre" select="$pre"/>
              <xsl:with-param name="current" select="$current"/>
              <xsl:with-param name="cm" select="$cm"/>
              <xsl:with-param name="cm2" select="$cm2"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="cha:else" mode="apatype">
              <xsl:with-param name="preatype" select="$preatype"/>
              <xsl:with-param name="prepron" select="$prepron"/>
              <xsl:with-param name="pre" select="$pre"/>
              <xsl:with-param name="current" select="$current"/>
              <xsl:with-param name="cm" select="$cm"/>
              <xsl:with-param name="cm2" select="$cm2"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:pre" mode="apatype">
    <xsl:param name="preatype"/>
    <xsl:param name="prepron"/>
    <xsl:param name="pre"/>
    <xsl:param name="current"/>
    <xsl:choose>
      <xsl:when test="@aConType">
        <xsl:call-template name="compare">
          <xsl:with-param name="std" select="@aConType"/>
          <xsl:with-param name="data" select="$pre/@aConType"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@aType">
        <xsl:call-template name="compare">
          <xsl:with-param name="std" select="@aType"/>
          <xsl:with-param name="data" select="$preatype"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@no_nucleus">
        <xsl:call-template name="chk-nonucleus">
          <xsl:with-param name="comp" select="@no_nucleus"/>
          <xsl:with-param name="aType" select="$preatype"/>
          <xsl:with-param name="pron" select="$prepron"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@tokushuhaku">
        <xsl:call-template name="chk-tokushuhaku">
          <xsl:with-param name="loc" select="@tokushuhaku"/>
          <xsl:with-param name="pron" select="$prepron"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cha:current" mode="apatype">
    <xsl:param name="preatype"/>
    <xsl:param name="prepron"/>
    <xsl:param name="pre"/>
    <xsl:param name="current"/>
    <xsl:choose>
      <xsl:when test="@aConType">
        <xsl:call-template name="compare">
          <xsl:with-param name="std" select="@aConType"/>
          <xsl:with-param name="data" select="$current/@aConType"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@aType">
        <xsl:call-template name="compare">
          <xsl:with-param name="aType" select="@aType"/>
          <xsl:with-param name="std">
            <xsl:call-template name="get-substring-before">
              <xsl:with-param name="string" select="$current/@aType"/>
              <xsl:with-param name="delim" select="','"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@no_nucleus">
        <xsl:call-template name="chk-nonucleus">
          <xsl:with-param name="comp" select="@no_nucleus"/>
          <xsl:with-param name="aType">
            <xsl:call-template name="get-substring-before">
              <xsl:with-param name="string" select="$current/@aType"/>
              <xsl:with-param name="delim" select="','"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="pron" select="$current/@pron"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@tokushuhaku">
        <xsl:call-template name="chk-tokushuhaku">
          <xsl:with-param name="loc" select="@tokushuhaku"/>
          <xsl:with-param name="pron" select="$current/@pron"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="compare">
    <xsl:param name="std"/>
    <xsl:param name="data"/>
    <xsl:choose>
      <xsl:when test="$data = $std">yes</xsl:when>
      <xsl:otherwise>no</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="chk-nonucleus">
    <xsl:param name="comp"/>
    <xsl:param name="aType"/>
    <xsl:param name="pron"/>
    <xsl:variable name="non">
      <xsl:choose>
        <xsl:when test="$aType = 0">yes</xsl:when>
        <xsl:otherwise>
          <xsl:variable name="len">
            <xsl:call-template name="calc-mora">
              <xsl:with-param name="pron" select="$pron"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$aType = $len">yes</xsl:when>
            <xsl:when test="$aType &lt; ($len - 1)">no</xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="chk-tokushuhaku">
                <xsl:with-param name="loc" select="-1"/>
                <xsl:with-param name="pron" select="$pron"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$comp = $non">yes</xsl:when>
      <xsl:otherwise>no</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-mora">
    <xsl:param name="pron"/>
    <xsl:value-of select="string-length($pron) - string-length(translate($pron, 'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴーッ', ''))"/>
  </xsl:template>

  <xsl:template name="chk-tokushuhaku">
    <xsl:param name="loc"/>
    <xsl:param name="pron"/>
    <xsl:variable name="wm" select="translate($pron, 'ァィゥェォャュョ', '')"/>
    <xsl:variable name="char" select="substring($wm, (string-length($wm) + $loc + 1), 1)"/>
    <xsl:choose>
      <xsl:when test="($char = 'ン') or ($char = 'ー') or ($char = 'ッ')">yes</xsl:when>
      <xsl:otherwise>no</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-atype-val">
    <xsl:param name="exp"/>
    <xsl:param name="preatype"/>
    <xsl:param name="prepron"/>
    <xsl:param name="pre"/>
    <xsl:param name="current"/>
    <xsl:param name="cm"/>
    <xsl:param name="cm2"/>
    <xsl:choose>
      <xsl:when test="contains($exp, '+')">
        <xsl:variable name="first">
          <xsl:call-template name="calc-atype-val">
            <xsl:with-param name="exp" select="normalize-space(substring-before($exp, '+'))"/>
            <xsl:with-param name="preatype" select="$preatype"/>
            <xsl:with-param name="prepron" select="$prepron"/>
            <xsl:with-param name="pre" select="$pre"/>
            <xsl:with-param name="current" select="$current"/>
            <xsl:with-param name="cm" select="$cm"/>
            <xsl:with-param name="cm2" select="$cm2"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="second">
          <xsl:call-template name="calc-atype-val">
            <xsl:with-param name="exp" select="normalize-space(substring-after($exp, '+'))"/>
            <xsl:with-param name="preatype" select="$preatype"/>
            <xsl:with-param name="prepron" select="$prepron"/>
            <xsl:with-param name="pre" select="$pre"/>
            <xsl:with-param name="current" select="$current"/>
            <xsl:with-param name="cm" select="$cm"/>
            <xsl:with-param name="cm2" select="$cm2"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$first + $second"/>
      </xsl:when>
      <xsl:when test="contains($exp, '-')">
        <xsl:variable name="first">
          <xsl:call-template name="calc-atype-val">
            <xsl:with-param name="exp" select="normalize-space(substring-before($exp, '-'))"/>
            <xsl:with-param name="preatype" select="$preatype"/>
            <xsl:with-param name="prepron" select="$prepron"/>
            <xsl:with-param name="pre" select="$pre"/>
            <xsl:with-param name="current" select="$current"/>
            <xsl:with-param name="cm" select="$cm"/>
            <xsl:with-param name="cm2" select="$cm2"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="second">
          <xsl:call-template name="calc-atype-val">
            <xsl:with-param name="exp" select="normalize-space(substring-after($exp, '-'))"/>
            <xsl:with-param name="preatype" select="$preatype"/>
            <xsl:with-param name="prepron" select="$prepron"/>
            <xsl:with-param name="pre" select="$pre"/>
            <xsl:with-param name="current" select="$current"/>
            <xsl:with-param name="cm" select="$cm"/>
            <xsl:with-param name="cm2" select="$cm2"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$first - $second"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="number($exp) = $exp">
            <xsl:value-of select="$exp"/>
          </xsl:when>
          <xsl:when test="$exp = 'current/@cm'">
            <xsl:value-of select="$cm"/>
          </xsl:when>
          <xsl:when test="$exp = 'current/@cm2'">
            <xsl:value-of select="$cm2"/>
          </xsl:when>
          <xsl:when test="$exp = 'pre/@mora'">
            <xsl:call-template name="calc-mora">
              <xsl:with-param name="pron" select="$prepron"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$exp = 'current/@mora'">
            <xsl:call-template name="calc-mora">
              <xsl:with-param name="pron" select="$current/@pron"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$exp = 'pre/@aType'">
            <xsl:value-of select="$preatype"/>
          </xsl:when>
          <xsl:when test="$exp = 'current/@aType'">
            <xsl:call-template name="get-substring-before">
              <xsl:with-param name="string" select="$current/@aType"/>
              <xsl:with-param name="delim" select="','"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
