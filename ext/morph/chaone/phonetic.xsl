<!-- XSLT stylesheet for ChaOne              -->
<!--              for xalan, msxml and exslt -->
<!--                            ver. 1.3.2   -->
<!--                        for UniDic 1.3.* -->
<!-- ChaOne consists of the followings;      -->
<!--  (2) Phonetic Alternation               -->
<!--                2008-04-22 by Studio ARC -->
<!-- Copyright (c) 2004-2008 Studio ARC      -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:msxml="urn:schemas-microsoft-com:xslt"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:cha="http://www.unidic.org/chasen/ns/structure/1.0"
  extension-element-prefixes="exsl msxml xalan"
  exclude-result-prefixes="exsl msxml xalan"
  version="1.0"
  xml:lang="ja">

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>

  <xsl:variable name="IPA_table" select="document('IPAfn.xml')"/>
 <xsl:variable name="FPA_table" select="document('FPAfn.xml')"/>
  <xsl:key name="IPAfn" match="cha:ifn" use="concat(@lForm, @lemma, @pron, @iType, @iForm, @iConType)"/>
  <xsl:key name="FPAfn" match="cha:ffn" use="concat(@lForm, @lemma, @pron, @fType, @fForm, @fConType)"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
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
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="chaone"/>
    </xsl:copy>
  </xsl:template>

  <!-- xsl:template match="@*|*" mode="chaone">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="chaone"/>
    </xsl:copy>
  </xsl:template -->

  <xsl:template match="@*" mode="chaone">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="*" mode="chaone">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="chaone"/>
      <xsl:apply-templates select="node()" mode="chaone"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="cha:W2[not(@pron)]" mode="chaone">
    <!-- pron属性を持たないW2に対する音韻交替処理 -->
    <!-- W2の子要素である各W1についての処理 -->
    <xsl:variable name="W1-list">
      <xsl:apply-templates mode="alt"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="pron">
        <xsl:choose>
          <xsl:when test="function-available('exsl:node-set')">
            <xsl:for-each select="exsl:node-set($W1-list)/cha:W1">
              <xsl:value-of select="@pron"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="function-available('msxml:node-set')">
            <xsl:for-each select="msxml:node-set($W1-list)/cha:W1">
              <xsl:value-of select="@pron"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="function-available('xalan:nodeset')">
            <xsl:for-each select="xalan:nodeset($W1-list)/cha:W1">
              <xsl:value-of select="@pron"/>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:copy-of select="$W1-list"/>
    </xsl:copy>
  </xsl:template>

  <!-- ChaOne inside W2 -->
  <xsl:template match="cha:W1" mode="alt">
    <xsl:variable name="iForm_position">
      <xsl:if test="@iForm">
        <xsl:call-template name="calc-iForm_position"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="fForm_position">
      <xsl:if test="@fForm or (@pos = '名詞-数詞')">
        <xsl:call-template name="calc-fForm_position"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="position">
      <xsl:choose>
        <xsl:when test="(@pos = '接尾辞-名詞的-助数詞') and starts-with(@lemma, '日')">
          <!-- 特殊処理 for '日' -->
          <xsl:call-template name="nichi_ka_select">
            <xsl:with-param name="prev1" select="preceding-sibling::*[1]"/>
            <xsl:with-param name="prev2" select="preceding-sibling::*[2]"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$fForm_position > 0">
          <xsl:value-of select="$fForm_position"/>
        </xsl:when>
        <xsl:when test="$iForm_position > 0">
          <xsl:value-of select="$iForm_position"/>
        </xsl:when>
        <xsl:when test="(preceding-sibling::cha:W1[1]/@pos = '名詞-数詞') and contains(@fConType, '/')">
          <xsl:call-template name="get_pos">
            <xsl:with-param name="str" select="@fConType"/>
            <xsl:with-param name="key">
              <xsl:call-template name="get_first">
                <xsl:with-param name="list" select="@fConType"/>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:call-template name="nth_attr">
          <xsl:with-param name="position" select="$position"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="nichi_ka_select">
    <xsl:param name="prev1" />
    <xsl:param name="prev2" />
    <xsl:variable name="post" select="substring-after(@lForm, '}')"/>
    <xsl:variable name="nichi_pos">
      <xsl:call-template name="get_pos">
        <xsl:with-param name="str" select="@lForm"/>
        <xsl:with-param name="key" select="'ニチ'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ka_pos">
      <xsl:call-template name="get_pos">
        <xsl:with-param name="str" select="@lForm"/>
        <xsl:with-param name="key" select="'カ'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$prev1/@lemma = '四'">
        <xsl:value-of select="$ka_pos"/>
      </xsl:when>
      <xsl:when test="not($prev2/@pos = '名詞-数詞') and contains(' 二 三 四 五 六 七 八 九 十 二十 ', concat(' ', $prev1/@lemma, ' '))">
        <xsl:value-of select="$ka_pos"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nichi_pos"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_pos">
    <xsl:param name="str" />
    <xsl:param name="key" />
    <xsl:choose>
      <xsl:when test="contains($str, $key)">
        <xsl:variable name="pre" select="substring-before($str, $key)"/>
        <xsl:value-of select="string-length($pre) - string-length(translate($pre, '/', '')) + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="nth_attr">
    <!-- current() = cha:W1/@* -->
    <!-- return nth value (slash separated) of attribute -->
    <xsl:param name="position"/>
    <xsl:attribute name="{name()}">
      <xsl:choose>
        <xsl:when test="contains(., '/')">
          <xsl:call-template name="nth_val">
            <xsl:with-param name="position" select="$position"/>
            <xsl:with-param name="pre" select="substring-before(., '{')"/>
            <xsl:with-param name="post" select="substring-after(., '}')"/>
            <xsl:with-param name="body" select="substring-before(substring-after(., '{'), '}')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="nth_val">
    <!-- current() = cha:W1/@* -->
    <!-- return nth value (slash separated) of attribute -->
    <!-- recursive -->
    <xsl:param name="position"/>
    <xsl:param name="pre"/>
    <xsl:param name="post"/>
    <xsl:param name="body"/>
    <xsl:choose>
      <xsl:when test="$position = 1">
        <xsl:choose>
          <xsl:when test="contains($body, '/')">
            <xsl:value-of select="concat($pre, substring-before($body, '/'), $post)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($pre, $body, $post)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="nth_val">
          <xsl:with-param name="position" select="$position - 1"/>
          <xsl:with-param name="pre" select="$pre"/>
          <xsl:with-param name="post" select="$post"/>
          <xsl:with-param name="body" select="substring-after($body, '/')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-iForm_position">
    <!-- current() = cha:W1 -->
    <!-- returns position (nth) of iForm or position of 基本形 -->
    <xsl:call-template name="calc-iForm_position_main">
      <xsl:with-param name="lForm" select="@lForm"/>
      <xsl:with-param name="lemma" select="@lemma"/>
      <xsl:with-param name="pron" select="@pron"/>
      <xsl:with-param name="iTypes" select="@iType"/>
      <xsl:with-param name="iConType">
        <xsl:call-template name="get_first">
          <xsl:with-param name="list" select="preceding-sibling::cha:W1[1]/@iConType"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="iForms" select="@iForm"/>
      <xsl:with-param name="position" select="1"/>
      <xsl:with-param name="kihonkei" select="0"/>
      <xsl:with-param name="loop" select="1"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="get_first">
    <!-- get non null first item -->
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, '{')">
        <xsl:call-template name="get_first_main">
          <xsl:with-param name="pre" select="substring-before($list, '{')"/>
          <xsl:with-param name="post" select="substring-after($list, '}')"/>
          <xsl:with-param name="list" select="substring-before(substring-after($list, '{'), '}')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$list"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_first_main">
    <xsl:param name="pre"/>
    <xsl:param name="post"/>
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, '/')">
        <xsl:variable name="first" select="substring-before($list, '/')"/>
        <xsl:choose>
          <xsl:when test="string-length($first) = 0">
            <xsl:call-template name="get_first_main">
              <xsl:with-param name="pre" select="$pre"/>
              <xsl:with-param name="post" select="$post"/>
              <xsl:with-param name="list" select="substring-after($list, '/')"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($pre, $first, $post)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($pre, $list, $post)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-iForm_position_main">
    <!-- current() = cha:W1 -->
    <!-- returns position (nth) of iForm whose ifn value = 1.0 -->
    <!-- recursive -->
    <xsl:param name="lForm"/>
    <xsl:param name="lemma"/>
    <xsl:param name="pron"/>
    <xsl:param name="iTypes"/>
    <xsl:param name="iConType"/>
    <xsl:param name="iForms"/>
    <xsl:param name="position"/>
    <xsl:param name="kihonkei"/>
    <xsl:param name="loop"/>
    <xsl:variable name="lForm_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$lForm"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="lemma_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$lemma"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pron_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$pron"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="iType">
      <xsl:choose>
        <xsl:when test="contains($iTypes, '/')">
          <xsl:call-template name="nth_val">
            <xsl:with-param name="position" select="$position"/>
            <xsl:with-param name="pre" select="substring-before($iTypes, '{')"/>
            <xsl:with-param name="post" select="substring-after($iTypes, '}')"/>
            <xsl:with-param name="body" select="substring-before(substring-after($iTypes, '{'), '}')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$iTypes"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="iForm">
      <xsl:choose>
        <xsl:when test="contains($iForms, '/')">
          <xsl:call-template name="nth_val">
            <xsl:with-param name="position" select="$position"/>
            <xsl:with-param name="pre" select="substring-before($iForms, '{')"/>
            <xsl:with-param name="post" select="substring-after($iForms, '}')"/>
            <xsl:with-param name="body" select="substring-before(substring-after($iForms, '{'), '}')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$iForms"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ifn_val">
      <xsl:for-each select="$IPA_table">
        <xsl:choose>
          <xsl:when test="$loop = 1">
            <xsl:value-of select="key('IPAfn', concat($lForm_1, $lemma_1, $pron_1, $iType, $iForm, $iConType))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="key('IPAfn', concat('*', '*', '*', $iType, $iForm, $iConType))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="fConType">
      <xsl:choose>
        <xsl:when test="contains(@fConType, '/')">
          <xsl:call-template name="nth_val">
            <xsl:with-param name="position" select="$position"/>
            <xsl:with-param name="pre" select="substring-before(@fConType, '{')"/>
            <xsl:with-param name="post" select="substring-after(@fConType, '}')"/>
            <xsl:with-param name="body" select="substring-before(substring-after(@fConType, '{'), '}')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@fConType"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not($fConType = '') and ($ifn_val = 1.0)">
        <xsl:value-of select="$position"/>
      </xsl:when>
      <xsl:when test="(string-length($iForms) - string-length(translate($iForms, '/', '')) + 1) >= $position">
        <!-- 基本形の探査のため，1回余分に回している -->
        <xsl:call-template name="calc-iForm_position_main">
          <xsl:with-param name="lForm">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$lForm"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="lemma">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$lemma"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="pron">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$pron"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="iTypes" select="$iTypes"/>
          <xsl:with-param name="iConType" select="$iConType"/>
          <xsl:with-param name="iForms" select="$iForms"/>
          <xsl:with-param name="position" select="$position + 1"/>
          <xsl:with-param name="kihonkei">
            <xsl:choose>
              <xsl:when test="$fConType and ($iForm = '基本形') and ($kihonkei = 0)">
                <xsl:value-of select="$position"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$kihonkei"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="loop" select="$loop"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$loop = 1">
            <xsl:call-template name="calc-iForm_position_main">
              <xsl:with-param name="lForm" select="@lForm"/>
              <xsl:with-param name="lemma" select="@lemma"/>
              <xsl:with-param name="pron" select="@pron"/>
              <xsl:with-param name="iTypes" select="@iType"/>
              <xsl:with-param name="iConType">
                <xsl:call-template name="get_first">
                  <xsl:with-param name="list" select="preceding-sibling::cha:W1[1]/@iConType"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="iForms" select="@iForm"/>
              <xsl:with-param name="position" select="1"/>
              <xsl:with-param name="kihonkei" select="0"/>
              <xsl:with-param name="loop" select="2"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="k_fconval">
              <xsl:if test="$kihonkei > 0">
                <xsl:choose>
                  <xsl:when test="contains(@fConType, '/')">
                    <xsl:call-template name="nth_val">
                      <xsl:with-param name="position" select="$kihonkei"/>
                      <xsl:with-param name="pre" select="substring-before(@fConType, '{')"/>
                      <xsl:with-param name="post" select="substring-after(@fConType, '}')"/>
                      <xsl:with-param name="body" select="substring-before(substring-after(@fConType, '{'), '}')"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@fConType"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="(string-length(@fConType) > 0) and ($k_fconval = '')">
                <xsl:value-of select="0"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$kihonkei"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-fForm_position">
    <!-- current() = cha:W1 -->
    <!-- returns position (nth) of fForm -->
    <xsl:call-template name="calc-fForm_position_main">
      <!-- F(lForm, lemma, pron, fType, fForm, fConType) -->
      <xsl:with-param name="lForm" select="@lForm"/>
      <xsl:with-param name="lemma" select="@lemma"/>
      <xsl:with-param name="pron" select="@pron"/>
      <xsl:with-param name="fType" select="@fType"/>
      <xsl:with-param name="fForm" select="@fForm"/>
      <xsl:with-param name="fConType">
        <xsl:call-template name="calc-fConType">
          <xsl:with-param name="fConTypes" select="following-sibling::cha:W1[1]/@fConType"/>
          <xsl:with-param name="insideN">
            <xsl:call-template name="chk_preceding_num">
              <xsl:with-param name="prevW1" select="preceding-sibling::cha:W1[1]"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="position" select="1"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="calc-fConType">
    <xsl:param name="fConTypes"/>
    <xsl:param name="insideN"/>
    <xsl:variable name="num" select="translate(substring(@lemma, string-length(@lemma)), '一二三四五六七八九十百', '123456789jh')"/>
    <xsl:variable name="fConType0">
      <xsl:choose>
        <xsl:when test="contains($fConTypes, '/')">
          <xsl:call-template name="get_first">
            <xsl:with-param name="list" select="$fConTypes"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$fConTypes"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fConType1">
      <xsl:choose>
        <xsl:when test="contains($fConType0, ',')">
          <xsl:value-of select="substring-before($fConType0, ',')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$fConType0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="starts-with(following-sibling::cha:W1/@orth, '日')">
        <!-- 特殊処理 for '日' -->
        <xsl:choose>
          <xsl:when test="$insideN = 1">
            <xsl:choose>
              <xsl:when test="$num = 4">
                <xsl:value-of select="'D'"/>
              </xsl:when>
              <xsl:when test="$num = 9">
                <xsl:value-of select="'9G'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'B'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'D'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="not(contains('123456789jh', $num)) or (2 > string-length($fConType1))">
        <xsl:value-of select="$fConType1"/>
      </xsl:when>
      <xsl:when test="contains($fConType1, $num)">
        <xsl:choose>
          <xsl:when test="(($insideN = 1) or (string-length(@lemma) > 1)) and starts-with(substring-after($fConType1, $num), 'W')">
            <xsl:value-of select="concat($num, substring(substring-after($fConType1, $num), 2, 1))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($num, substring(substring-after($fConType1, $num), 1, 1))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($num, substring($fConType1, 1, 1))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="chk_preceding_num">
    <xsl:param name="prevW1"/>
    <xsl:if test="$prevW1/@pos = '名詞-数詞' and contains('十百千万億兆', substring($prevW1/@lemma, string-length($prevW1/@lemma)))">
      <xsl:value-of select="1"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="calc-fForm_position_main">
    <!-- current() = cha:W1 -->
    <!-- returns position (nth) of fForm whose ffn value = 1.0 -->
    <!-- recursive -->
    <xsl:param name="lForm"/>
    <xsl:param name="lemma"/>
    <xsl:param name="pron"/>
    <xsl:param name="fType"/>
    <xsl:param name="fForm"/>
    <xsl:param name="fConType"/>
    <xsl:param name="position"/>
    <xsl:variable name="lForm_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$lForm"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="lemma_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$lemma"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pron_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$pron"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="fType_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$fType"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="fForm_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$fForm"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ffn_val">
      <xsl:for-each select="$FPA_table">
        <xsl:value-of select="key('FPAfn', concat($lForm_1, $lemma_1, $pron_1, $fType_1, $fForm_1, $fConType))"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$ffn_val = 1.0">
        <xsl:value-of select="$position"/>
      </xsl:when>
      <xsl:when test="contains($pron, '/')">
        <xsl:call-template name="calc-fForm_position_main">
          <xsl:with-param name="lForm">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$lForm"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="lemma">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$lemma"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="pron">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$pron"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="fType">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$fType"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="fForm">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$fForm"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="fConType" select="$fConType"/>
          <xsl:with-param name="position" select="$position + 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_head">
    <!-- get first item -->
    <xsl:param name="list"/>
    <xsl:variable name="head">
      <xsl:choose>
        <xsl:when test="contains($list, '{')">
          <xsl:call-template name="get_head_main">
            <xsl:with-param name="pre" select="substring-before($list, '{')"/>
            <xsl:with-param name="post" select="substring-after($list, '}')"/>
            <xsl:with-param name="list" select="substring-before(substring-after($list, '{'), '}')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$list"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$head = ''">
        <xsl:value-of select="'null'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$head"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_head_main">
    <xsl:param name="pre"/>
    <xsl:param name="post"/>
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, '/')">
        <xsl:value-of select="concat($pre, substring-before($list, '/'), $post)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($pre, $list, $post)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_rest">
    <!-- get rest item -->
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, '{')">
        <xsl:call-template name="get_rest_main">
          <xsl:with-param name="pre" select="substring-before($list, '{')"/>
          <xsl:with-param name="post" select="substring-after($list, '}')"/>
          <xsl:with-param name="list" select="substring-before(substring-after($list, '{'), '}')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$list"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_rest_main">
    <xsl:param name="pre"/>
    <xsl:param name="post"/>
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, '/')">
        <xsl:value-of select="concat($pre, '{', substring-after($list, '/'), '}', $post)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($pre, '{', $list, '}', $post)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
