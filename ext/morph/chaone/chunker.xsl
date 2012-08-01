<!-- XSLT stylesheet for ChaOne              -->
<!--              for xalan, msxml and exslt -->
<!--                              ver. 1.3.2 -->
<!--  (1) ChaSen Chunker                     -->
<!--                2008-02-12 by Studio ARC -->
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

  <xsl:variable name="chunk_rules" select="document('chunk_rules.xml')/cha:chunk_rules"/>

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
      <xsl:apply-templates mode="chunker"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[not(self::cha:W1)]" priority="-10" mode="chunker">
    <!-- W1以外の処理 -->
    <xsl:choose>
      <xsl:when test="*">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates select="*" mode="chunker"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" priority="-10" mode="chunker">
  </xsl:template>

  <xsl:template match="cha:W1[(position() = 1)
                          or (preceding-sibling::cha:W1[1][@w2Chunk = 'E'])
                          or (preceding-sibling::*[1][not(self::cha:W1)])]" mode="chunker">
    <!-- 先頭ないしEの後ろないしW1以外のノードの後ろのノードを選択 -->
    <!-- 先頭ないしEの後ろないしW1以外のノードの後ろから、最後ないしBないしW1以外の前までのノードが対象 -->
    <xsl:call-template name="select-target"/>
  </xsl:template>

  <xsl:template name="select-target">
    <!-- 規則適用範囲の決定と適用 -->
    <!-- current = "cha:W1" -->
    <xsl:variable name="from">
      <xsl:apply-templates select="." mode="get-position"/>
    </xsl:variable>
    <xsl:variable name="to">
      <xsl:call-template name="calc-to">
        <xsl:with-param name="from" select="$from"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="selected-rules">
      <xsl:call-template name="select-rules">
        <xsl:with-param name="input" select="parent::*[1]"/>
        <xsl:with-param name="from" select="$from"/>
        <xsl:with-param name="to" select="$to"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="rules">
      <xsl:choose>
        <xsl:when test="function-available('exsl:node-set')">
          <xsl:for-each select="exsl:node-set($selected-rules)/range">
            <xsl:sort select="@from" data-type="number"/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="function-available('msxml:node-set')">
          <xsl:for-each select="msxml:node-set($selected-rules)/range">
            <xsl:sort select="@from" data-type="number"/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="function-available('xalan:nodeset')">
          <xsl:for-each select="xalan:nodeset($selected-rules)/range">
            <xsl:sort select="@from" data-type="number"/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="function-available('exsl:node-set')">
        <xsl:call-template name="apply-rules">
          <xsl:with-param name="input" select="parent::*[1]"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
          <xsl:with-param name="rules" select="exsl:node-set($rules)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="function-available('msxml:node-set')">
        <xsl:call-template name="apply-rules">
          <xsl:with-param name="input" select="parent::*[1]"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
          <xsl:with-param name="rules" select="msxml:node-set($rules)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="function-available('xalan:nodeset')">
        <xsl:call-template name="apply-rules">
          <xsl:with-param name="input" select="parent::*[1]"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
          <xsl:with-param name="rules" select="xalan:nodeset($rules)"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-to">
    <!-- 最後ないしBの前ないしW1以外のノードの前のノードのうち最も前の位置を返す -->
    <xsl:param name="from"/>
    <xsl:variable name="Bpos">
      <xsl:if test="following-sibling::cha:W1[@w2Chunk = 'B']">
        <xsl:choose>
          <xsl:when test="following-sibling::cha:W1[1][@w2Chunk = 'B']">
            <xsl:value-of select="$from"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates
              select="following-sibling::cha:W1[not(@w2Chunk)][following-sibling::cha:W1[1][@w2Chunk = 'B']][1]"
              mode="get-position"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="nonW1pos">
      <xsl:if test="following-sibling::*[not(self::cha:W1)]">
        <xsl:variable name="nonW1poscand">
          <xsl:choose>
            <xsl:when test="following-sibling::*[1][not(self::cha:W1)]">
              <xsl:value-of select="$from"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates
                select="following-sibling::cha:W1[following-sibling::*[1][not(self::cha:W1)]][1]"
                mode="get-position"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="number($nonW1poscand)">
            <xsl:value-of select="$nonW1poscand"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$from"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="lastpos">
      <xsl:apply-templates
        select="following-sibling::cha:W1[last()]"
        mode="get-position"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="number($Bpos) and number($nonW1pos)">
        <xsl:choose>
          <xsl:when test="number($nonW1pos) > number($Bpos)">
            <xsl:value-of select="$Bpos"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$nonW1pos"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="number($Bpos)">
        <xsl:value-of select="$Bpos"/>
      </xsl:when>
      <xsl:when test="number($nonW1pos)">
        <xsl:value-of select="$nonW1pos"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="number($lastpos)">
            <xsl:value-of select="$lastpos"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$from"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="node()" mode="get-position">
    <xsl:value-of select="count(preceding-sibling::*) + 1"/>
  </xsl:template>

  <xsl:template name="select-rules">
    <!-- current = "cha:W1" -->
    <!-- returns <range rule="id" from="from" to="to"/>... -->
    <xsl:param name="input"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <!-- 適用可能なすべての規則について'id,from,to'を計算する -->
    <xsl:variable name="applicable-rules">
      <xsl:for-each select="$chunk_rules/cha:rule">
        <xsl:call-template name="check-rule">
          <xsl:with-param name="input" select="$input"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <!-- このうち適用範囲の広いものから順に両立可能なもの -->
    <xsl:variable name="sorted-rules">
      <xsl:choose>
        <xsl:when test="function-available('exsl:node-set')">
          <xsl:for-each select="exsl:node-set($applicable-rules)/range">
            <xsl:sort select="@to - @from" order="descending" data-type="number"/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="function-available('msxml:node-set')">
          <xsl:for-each select="msxml:node-set($applicable-rules)/range">
            <xsl:sort select="@to - @from" order="descending" data-type="number"/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="function-available('xalan:nodeset')">
          <xsl:for-each select="xalan:nodeset($applicable-rules)/range">
            <xsl:sort select="@to - @from" order="descending" data-type="number"/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="function-available('exsl:node-set')">
        <xsl:apply-templates select="exsl:node-set($sorted-rules)/range" mode="chk"/>
      </xsl:when>
      <xsl:when test="function-available('msxml:node-set')">
        <xsl:apply-templates select="msxml:node-set($sorted-rules)/range" mode="chk"/>
      </xsl:when>
      <xsl:when test="function-available('xalan:nodeset')">
        <xsl:apply-templates select="xalan:nodeset($sorted-rules)/range" mode="chk"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="range" mode="chk">
    <xsl:variable name="rfrom" select="@from"/>
    <xsl:variable name="rto" select="@to"/>
    <xsl:variable name="chk">
      <xsl:for-each select="preceding-sibling::range">
        <xsl:choose>
          <xsl:when test="(number($rto) &lt; number(@from)) or (number($rfrom) > number(@to))">
            <xsl:text>T</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>F</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="not(contains($chk, 'F'))">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="check-rule">
    <!-- 特定のruleが$fromから$toの範囲のどこかに適用可能かどうかのチェック -->
    <!-- 当該ruleのrhsがすべて満たされるかどうか -->
    <!-- current = "rule" -->
    <!-- returns <range id="id" from="from" to="to"/>... -->
    <xsl:param name="input"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:variable name="results">
      <xsl:call-template name="check-rule-top">
        <xsl:with-param name="input" select="$input"/>
        <xsl:with-param name="from" select="$from"/>
        <xsl:with-param name="to" select="$to"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- return value -->
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
      <xsl:when test="function-available('exsl:node-set')">
        <xsl:apply-templates select="exsl:node-set($results)/range" mode="result">
          <xsl:with-param name="id" select="$id"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="function-available('msxml:node-set')">
        <xsl:apply-templates select="msxml:node-set($results)/range" mode="result">
          <xsl:with-param name="id" select="$id"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="function-available('xalan:nodeset')">
        <xsl:apply-templates select="xalan:nodeset($results)/range" mode="result">
          <xsl:with-param name="id" select="$id"/>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="range" mode="result">
    <xsl:param name="id"/>
    <xsl:copy>
      <xsl:attribute name="id">
        <xsl:value-of select="$id"/>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="check-rule-top">
    <!-- returns <range from="from" to="to"/> ... -->
    <!-- current = "rule" -->
    <xsl:param name="input"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:variable name="targets"
                  select="$input/*[(position() >= number($from)) and (position() &lt;= number($to))]"/>
    <xsl:choose>
      <!-- rhsのトップにはW1ないしchoiceがあると仮定 -->
      <xsl:when test="cha:rhs/cha:W1">
        <!-- rhsのトップの先頭のW1について処理 -->
        <xsl:variable name="rhs-cur" select="cha:rhs/cha:W1[1]"/>
        <xsl:variable name="rhs-pre" select="cha:rhs/*[generate-id(following-sibling::cha:W1[1]) = generate-id($rhs-cur)]"/>
        <xsl:variable name="rhs-post" select="cha:rhs/*[generate-id(preceding-sibling::cha:W1[last()]) = generate-id($rhs-cur)]"/>
        <xsl:choose>
          <xsl:when test="$targets[self::cha:W1 and contains(@pos, $rhs-cur/@pos)]">
            <xsl:variable name="hit-locs">
              <xsl:for-each select="$targets[self::cha:W1 and contains(@pos, $rhs-cur/@pos)]">
                <hit>
                  <xsl:apply-templates select="." mode="get-position"/>
                </hit>
                </xsl:for-each>
            </xsl:variable>
            <!-- $targetsのうち条件を満たすすべてのW1について処理 -->
            <xsl:variable name="results">
              <xsl:choose>
                <xsl:when test="function-available('exsl:node-set')">
                  <xsl:for-each select="exsl:node-set($hit-locs)/hit">
                    <xsl:call-template name="calc-result">
                      <xsl:with-param name="input" select="$input"/>
                      <xsl:with-param name="hit-loc" select="."/>
                      <xsl:with-param name="rhs-pre" select="$rhs-pre"/>
                      <xsl:with-param name="rhs-post" select="$rhs-post"/>
                      <xsl:with-param name="from" select="$from"/>
                      <xsl:with-param name="to" select="$to"/>
                    </xsl:call-template>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="function-available('msxml:node-set')">
                  <xsl:for-each select="msxml:node-set($hit-locs)/hit">
                    <xsl:call-template name="calc-result">
                      <xsl:with-param name="input" select="$input"/>
                      <xsl:with-param name="hit-loc" select="."/>
                      <xsl:with-param name="rhs-pre" select="$rhs-pre"/>
                      <xsl:with-param name="rhs-post" select="$rhs-post"/>
                      <xsl:with-param name="from" select="$from"/>
                      <xsl:with-param name="to" select="$to"/>
                    </xsl:call-template>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="function-available('xalan:nodeset')">
                  <xsl:for-each select="xalan:nodeset($hit-locs)/hit">
                    <xsl:call-template name="calc-result">
                      <xsl:with-param name="input" select="$input"/>
                      <xsl:with-param name="hit-loc" select="."/>
                      <xsl:with-param name="rhs-pre" select="$rhs-pre"/>
                      <xsl:with-param name="rhs-post" select="$rhs-post"/>
                      <xsl:with-param name="from" select="$from"/>
                      <xsl:with-param name="to" select="$to"/>
                    </xsl:call-template>
                  </xsl:for-each>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:copy-of select="$results"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>F</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="cha:rhs/cha:choice">
      <!-- *** -->
      </xsl:when>
      <!--
      <xsl:when test="cha:rhs/cha:zeroOrMore">
      </xsl:when>
      <xsl:when test="cha:rhs/cha:oneOrMore">
      </xsl:when>
      <xsl:when test="cha:rhs/cha:optional">
      </xsl:when>
      -->
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-result">
    <!-- current = "rule" -->
    <!-- returns <range from="from" to="to"/> or 'F' -->
    <xsl:param name="input"/>
    <xsl:param name="hit-loc"/>
    <xsl:param name="rhs-pre"/>
    <xsl:param name="rhs-post"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:variable name="rhs-pre-result">
      <xsl:if test="count($rhs-pre)">
        <xsl:call-template name="check-rule-pre">
          <xsl:with-param name="input" select="$input"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$hit-loc - 1"/>
          <xsl:with-param name="rhs" select="$rhs-pre"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="rhs-post-result">
      <xsl:if test="count($rhs-post)">
        <xsl:call-template name="check-rule-post">
          <xsl:with-param name="input" select="$input"/>
          <xsl:with-param name="from" select="$hit-loc + 1"/>
          <xsl:with-param name="to" select="$to"/>
          <xsl:with-param name="rhs" select="$rhs-post"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="($rhs-pre-result = 'F') or ($rhs-post-result = 'F')">
        <xsl:text>F</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="range">
          <xsl:attribute name="from">
            <xsl:choose>
              <xsl:when test="$rhs-pre-result = 'NaN'">
                <xsl:value-of select="$from"/>
              </xsl:when>
              <xsl:when test="$rhs-pre-result != ''">
                <xsl:value-of select="$rhs-pre-result"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$hit-loc"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="to">
            <xsl:choose>
              <xsl:when test="$rhs-post-result = 'NaN'">
                <xsl:value-of select="$to"/>
              </xsl:when>
              <xsl:when test="$rhs-post-result != ''">
                <xsl:value-of select="$rhs-post-result"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$hit-loc"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="check-rule-pre">
    <!-- returns 'from' or 'F' -->
    <!-- current = "text()" -->
    <xsl:param name="input"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:param name="rhs"/>
    <xsl:call-template name="check-rule-des">
      <xsl:with-param name="input" select="$input"/>
      <xsl:with-param name="dir" select="'pre'"/>
      <xsl:with-param name="from" select="$from"/>
      <xsl:with-param name="to" select="$to"/>
      <xsl:with-param name="rhs" select="$rhs"/>
      <xsl:with-param name="rhs-cur" select="$rhs[last()]"/>
      <xsl:with-param name="rhs-des" select="$rhs[position() != last()]"/>
      <xsl:with-param name="target-cur" select="$input/*[number($to)]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="check-rule-post">
    <!-- returns 'to' or 'F' -->
    <!-- current = "text()" -->
    <xsl:param name="input"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:param name="rhs"/>
    <xsl:call-template name="check-rule-des">
      <xsl:with-param name="input" select="$input"/>
      <xsl:with-param name="dir" select="'post'"/>
      <xsl:with-param name="from" select="$from"/>
      <xsl:with-param name="to" select="$to"/>
      <xsl:with-param name="rhs" select="$rhs"/>
      <xsl:with-param name="rhs-cur" select="$rhs[1]"/>
      <xsl:with-param name="rhs-des" select="$rhs[position() != 1]"/>
      <xsl:with-param name="target-cur" select="$input/*[number($from)]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="check-rule-des">
    <!-- returns 'from | to' or 'F' -->
    <!-- current = "text()" -->
    <xsl:param name="input"/>
    <xsl:param name="dir"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:param name="rhs"/>
    <xsl:param name="rhs-cur"/>
    <xsl:param name="rhs-des"/>
    <xsl:param name="target-cur"/>
    <xsl:variable name="targets" select="$input/*[(position() >= number($from)) and (position() &lt;= number($to))]"/>
    <xsl:variable name="end">
      <xsl:choose>
        <xsl:when test="$dir = 'pre'">
          <xsl:value-of select="$from"/>
        </xsl:when>
        <xsl:when test="$dir = 'post'">
          <xsl:value-of select="$to"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$rhs-cur[local-name() = 'W1']">
        <xsl:choose>
          <xsl:when test="$target-cur[starts-with(@pos, $rhs-cur/@pos)]">
            <xsl:call-template name="check-rule-des-next-one">
              <xsl:with-param name="input" select="$input"/>
              <xsl:with-param name="dir" select="$dir"/>
              <xsl:with-param name="end" select="$end"/>
              <xsl:with-param name="rhs-des" select="$rhs-des"/>
              <xsl:with-param name="target-cur" select="$target-cur"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>F</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$rhs-cur[local-name() = 'zeroOrMore']">
      <!-- 子としてW1ないしchoiceを一つだけもつ -->
        <xsl:choose>
          <xsl:when test="$rhs-cur/cha:W1">
            <xsl:choose>
              <xsl:when test="$target-cur[starts-with(@pos, $rhs-cur/cha:W1/@pos)]">
                <!-- $targets のうち、最後尾から見て条件を満たす並びの先頭 -->
                <xsl:call-template name="check-rule-des-next-more">
                  <xsl:with-param name="input" select="$input"/>
                  <xsl:with-param name="dir" select="$dir"/>
                  <xsl:with-param name="end" select="$end"/>
                  <xsl:with-param name="rhs-des" select="$rhs-des"/>
                  <xsl:with-param name="rhs-cur" select="$rhs-cur"/>
                  <xsl:with-param name="targets" select="$targets"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <!-- next processing -->
                <xsl:call-template name="check-rule-des-next-zero">
                  <xsl:with-param name="input" select="$input"/>
                  <xsl:with-param name="dir" select="$dir"/>
                  <xsl:with-param name="end" select="$end"/>
                  <xsl:with-param name="rhs-des" select="$rhs-des"/>
                  <xsl:with-param name="from" select="$from"/>
                  <xsl:with-param name="to" select="$to"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$rhs-cur/cha:choice">
            <!-- select candidate that matches target-cur -->
            <xsl:variable name="choice-res">
              <xsl:for-each select="$rhs-cur/cha:choice/cha:W1">
                <xsl:if test="$target-cur[starts-with(@pos, ./@pos)]">
                  <xsl:text>T</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="contains($choice-res, 'T')">
                <xsl:call-template name="check-rule-des-next-more">
                  <xsl:with-param name="input" select="$input"/>
                  <xsl:with-param name="dir" select="$dir"/>
                  <xsl:with-param name="end" select="$end"/>
                  <xsl:with-param name="rhs-des" select="$rhs-des"/>
                  <xsl:with-param name="rhs-cur" select="$rhs-cur"/>
                  <xsl:with-param name="targets" select="$targets"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <!-- next processing -->
                <xsl:call-template name="check-rule-des-next-zero">
                  <xsl:with-param name="input" select="$input"/>
                  <xsl:with-param name="dir" select="$dir"/>
                  <xsl:with-param name="end" select="$end"/>
                  <xsl:with-param name="rhs-des" select="$rhs-des"/>
                  <xsl:with-param name="from" select="$from"/>
                  <xsl:with-param name="to" select="$to"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!--
      <xsl:when test="$rhs-cur[local-name() = 'oneOrMore']">
      </xsl:when>
      -->
      <xsl:when test="$rhs-cur[local-name() = 'optional']">
        <!-- 子としてW1ないしchoiceを一つだけもつ -->
        <xsl:choose>
          <xsl:when test="$rhs-cur/cha:W1">
            <xsl:choose>
              <xsl:when test="$target-cur[starts-with(@pos, $rhs-cur/cha:W1/@pos)]">
                <xsl:call-template name="check-rule-des-next-one">
                  <xsl:with-param name="input" select="$input"/>
                  <xsl:with-param name="dir" select="$dir"/>
                  <xsl:with-param name="end" select="$end"/>
                  <xsl:with-param name="rhs-des" select="$rhs-des"/>
                  <xsl:with-param name="target-cur" select="$target-cur"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <!-- next processing -->
                <xsl:call-template name="check-rule-des-next-zero">
                  <xsl:with-param name="input" select="$input"/>
                  <xsl:with-param name="dir" select="$dir"/>
                  <xsl:with-param name="end" select="$end"/>
                  <xsl:with-param name="rhs-des" select="$rhs-des"/>
                  <xsl:with-param name="from" select="$from"/>
                  <xsl:with-param name="to" select="$to"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$rhs-cur/cha:choice">
            <!-- select candidate that matches target-cur -->
            <xsl:variable name="choice-res">
              <xsl:for-each select="$rhs-cur/cha:choice/cha:W1">
                <xsl:if test="$target-cur[starts-with(@pos, ./@pos)]">
                  <xsl:text>T</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="contains($choice-res, 'T')">
                <xsl:call-template name="check-rule-des-next-one">
                  <xsl:with-param name="input" select="$input"/>
                  <xsl:with-param name="dir" select="$dir"/>
                  <xsl:with-param name="end" select="$end"/>
                  <xsl:with-param name="rhs-des" select="$rhs-des"/>
                  <xsl:with-param name="target-cur" select="$target-cur"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <!-- next processing -->
                <xsl:call-template name="check-rule-des-next-zero">
                  <xsl:with-param name="input" select="$input"/>
                  <xsl:with-param name="dir" select="$dir"/>
                  <xsl:with-param name="end" select="$end"/>
                  <xsl:with-param name="rhs-des" select="$rhs-des"/>
                  <xsl:with-param name="from" select="$from"/>
                  <xsl:with-param name="to" select="$to"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$rhs-cur[local-name() = 'choice']">
        <!-- select candidate that matches target-cur -->
        <xsl:variable name="choice-res">
          <xsl:for-each select="$rhs-cur/cha:W1">
            <xsl:if test="$target-cur[starts-with(@pos, ./@pos)]">
              <xsl:text>T</xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($choice-res, 'T')">
            <xsl:call-template name="check-rule-des-next-one">
              <xsl:with-param name="input" select="$input"/>
              <xsl:with-param name="dir" select="$dir"/>
              <xsl:with-param name="end" select="$end"/>
              <xsl:with-param name="rhs-des" select="$rhs-des"/>
              <xsl:with-param name="target-cur" select="$target-cur"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>F</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="des-bound">
    <xsl:param name="dir"/>
    <xsl:param name="rhs-cur"/>
    <xsl:param name="targets"/>
    <xsl:choose>
      <xsl:when test="$dir = 'pre'">
        <xsl:choose>
          <xsl:when test="$rhs-cur/cha:W1">
            <xsl:variable name="nomatch" select="$targets[not(starts-with(@pos, $rhs-cur/cha:W1/@pos))]"/>
            <xsl:choose>
              <xsl:when test="count($nomatch)">
                <xsl:variable name="nmlp">
                  <xsl:apply-templates select="$nomatch[last()]" mode="get-position"/>
                </xsl:variable>
                <xsl:value-of select="$nmlp + 1"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$targets[1]" mode="get-position"/>
              </xsl:otherwise>
            </xsl:choose>      
          </xsl:when>
          <xsl:when test="$rhs-cur/cha:choice">
            <xsl:variable name="nmlocs">
              <xsl:for-each select="$targets">
                <xsl:variable name="ct" select="."/>
                <xsl:variable name="chit">
                  <xsl:for-each select="$rhs-cur/cha:choice/cha:W1">
                    <xsl:if test="starts-with($ct/@pos, @pos)">
                      <xsl:text>T</xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:if test="not(contains($chit, 'T'))">
                  <xsl:text>#</xsl:text>
                  <xsl:value-of select="position()"/>
                  <xsl:text>#</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="nomatch" select="$targets[contains($nmlocs, concat('#', position(), '#'))]"/>
            <xsl:choose>
              <xsl:when test="count($nomatch)">
                <xsl:variable name="nmlp">
                  <xsl:apply-templates select="$nomatch[last()]" mode="get-position"/>
                </xsl:variable>
                <xsl:value-of select="$nmlp + 1"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$targets[1]" mode="get-position"/>
              </xsl:otherwise>
            </xsl:choose>      
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$dir = 'post'">
        <xsl:choose>
          <xsl:when test="$rhs-cur/cha:W1">
            <xsl:variable name="nomatch" select="$targets[not(starts-with(@pos, $rhs-cur/cha:W1/@pos))]"/>
            <xsl:choose>
              <xsl:when test="count($nomatch)">
                <xsl:variable name="nmfp">
                  <xsl:apply-templates select="$nomatch[1]" mode="get-position"/>
                </xsl:variable>
                <xsl:value-of select="$nmfp - 1"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$targets[last()]" mode="get-position"/>
              </xsl:otherwise>
            </xsl:choose>      
          </xsl:when>
          <xsl:when test="$rhs-cur/cha:choice">
            <xsl:variable name="nmlocs">
              <xsl:for-each select="$targets">
                <xsl:variable name="ct" select="."/>
                <xsl:variable name="chit">
                  <xsl:for-each select="$rhs-cur/cha:choice/cha:W1">
                    <xsl:if test="starts-with($ct/@pos, @pos)">
                      <xsl:text>T</xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:if test="not(contains($chit, 'T'))">
                  <xsl:text>#</xsl:text>
                  <xsl:value-of select="position()"/>
                  <xsl:text>#</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="nomatch" select="$targets[contains($nmlocs, concat('#', position(), '#'))]"/>
            <xsl:choose>
              <xsl:when test="count($nomatch)">
                <xsl:variable name="nmfp">
                  <xsl:apply-templates select="$nomatch[1]" mode="get-position"/>
                </xsl:variable>
                <xsl:value-of select="$nmfp - 1"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$targets[last()]" mode="get-position"/>
              </xsl:otherwise>
            </xsl:choose>      
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="check-rule-des-next-one">
    <xsl:param name="input"/>
    <xsl:param name="dir"/>
    <xsl:param name="end"/>
    <xsl:param name="rhs-des"/>
    <xsl:param name="target-cur"/>
    <xsl:call-template name="check-rule-des-next-main">
      <xsl:with-param name="input" select="$input"/>
      <xsl:with-param name="dir" select="$dir"/>
      <xsl:with-param name="end" select="$end"/>
      <xsl:with-param name="rhs-des" select="$rhs-des"/>
      <xsl:with-param name="hit-loc">
        <xsl:apply-templates select="$target-cur" mode="get-position"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="check-rule-des-next-more">
    <xsl:param name="input"/>
    <xsl:param name="dir"/>
    <xsl:param name="end"/>
    <xsl:param name="rhs-des"/>
    <xsl:param name="rhs-cur"/>
    <xsl:param name="targets"/>
    <xsl:call-template name="check-rule-des-next-main">
      <xsl:with-param name="input" select="$input"/>
      <xsl:with-param name="dir" select="$dir"/>
      <xsl:with-param name="end" select="$end"/>
      <xsl:with-param name="rhs-des" select="$rhs-des"/>
      <xsl:with-param name="hit-loc">
        <xsl:call-template name="des-bound">
          <xsl:with-param name="dir" select="$dir"/>
          <xsl:with-param name="rhs-cur" select="$rhs-cur"/>
          <xsl:with-param name="targets" select="$targets"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="check-rule-des-next-zero">
    <xsl:param name="input"/>
    <xsl:param name="dir"/>
    <xsl:param name="end"/>
    <xsl:param name="rhs-des"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:call-template name="check-rule-des-next-main">
      <xsl:with-param name="input" select="$input"/>
      <xsl:with-param name="dir" select="$dir"/>
      <xsl:with-param name="end" select="$end"/>
      <xsl:with-param name="rhs-des" select="$rhs-des"/>
      <xsl:with-param name="hit-loc">
        <xsl:choose>
          <xsl:when test="$dir = 'pre'">
            <xsl:value-of select="$to + 1"/>
          </xsl:when>
          <xsl:when test="$dir = 'post'">
            <xsl:value-of select="$from - 1"/>
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="check-rule-des-next-main">
    <!-- current = "text()" -->
    <xsl:param name="input"/>
    <xsl:param name="dir"/>
    <xsl:param name="end"/>
    <xsl:param name="rhs-des"/>
    <xsl:param name="hit-loc"/>
    <xsl:variable name="rhs-des-result">
      <xsl:if test="count($rhs-des)">
       	<xsl:choose>
          <xsl:when test="$dir = 'pre'">
            <!-- *** recursive call *** -->
            <xsl:call-template name="check-rule-des">
              <xsl:with-param name="input" select="$input"/>
              <xsl:with-param name="dir" select="$dir"/>
              <xsl:with-param name="from" select="$end"/>
              <xsl:with-param name="to" select="$hit-loc - 1"/>
              <xsl:with-param name="rhs" select="$rhs-des"/>
              <xsl:with-param name="rhs-cur" select="$rhs-des[last()]"/>
              <xsl:with-param name="rhs-des" select="$rhs-des[position() != last()]"/>
              <xsl:with-param name="target-cur" select="$input/*[number($hit-loc) - 1]"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$dir = 'post'">
            <!-- *** recursive call *** -->
            <xsl:call-template name="check-rule-des">
              <xsl:with-param name="input" select="$input"/>
              <xsl:with-param name="dir" select="$dir"/>
              <xsl:with-param name="from" select="$hit-loc + 1"/>
              <xsl:with-param name="to" select="$end"/>
              <xsl:with-param name="rhs" select="$rhs-des"/>
              <xsl:with-param name="rhs-cur" select="$rhs-des[1]"/>
              <xsl:with-param name="rhs-des" select="$rhs-des[position() != 1]"/>
              <xsl:with-param name="target-cur" select="$input/*[number($hit-loc) + 1]"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$rhs-des-result = 'F'">
        <xsl:text>F</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$rhs-des-result != ''">
            <xsl:value-of select="$rhs-des-result"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$hit-loc"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- 書き換え規則にマッチしたW1ノードセットからのW2の作成 -->

  <xsl:template name="apply-rules">
    <xsl:param name="input"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:param name="rules"/>
    <xsl:apply-templates select="$rules/range" mode="apply">
      <xsl:with-param name="input" select="$input"/>
      <xsl:with-param name="from" select="$from"/>
      <xsl:with-param name="to" select="$to"/>
      <xsl:with-param name="rules" select="$rules"/>
    </xsl:apply-templates>
    <xsl:variable name="lastto" select="$rules/range[last()]/@to"/>
    <xsl:variable name="last">
      <xsl:choose>
        <xsl:when test="$lastto >= 0">
          <xsl:value-of select="number($lastto) + 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$from"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="number($to) >= number($last)">
      <xsl:for-each select="$input/*[(position() >= number($last)) and (position() &lt;= number($to))]">
        <xsl:call-template name="wrapW1">
          <xsl:with-param name="target" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="wrapW1">
    <xsl:param name="target"/>
    <xsl:choose>
      <xsl:when test="$target[local-name() = 'W1']">
        <cha:W2>
          <!-- xsl:copy-of select="@*[(name() = 'orth') or (name() = 'pron') or (name() = 'pos')]"/ -->
          <xsl:copy-of select="@*[(name() = 'orth') or (name() = 'pos') or (name() = 'cType') or (name() = 'cForm')]"/>
          <xsl:copy-of select="$target"/>
        </cha:W2>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$target"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="range" mode="apply">
    <xsl:param name="input"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:param name="rules"/>
    <xsl:variable name="last">
      <xsl:choose>
        <xsl:when test="position() = 1">
          <xsl:value-of select="$from"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="number(preceding-sibling::range[1]/@to) + 1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rid" select="@id"/>
    <xsl:variable name="rfrom" select="@from"/>
    <xsl:variable name="rto" select="@to"/>
    <xsl:if test="number($last) &lt; number(@from)">
      <xsl:for-each select="$input/*[(position() >= number($last)) and (position() &lt; number($rfrom))]">
        <xsl:call-template name="wrapW1">
          <xsl:with-param name="target" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
    <cha:W2>
      <xsl:attribute name="orth">
        <xsl:for-each select="$input/*[(position() >= number($rfrom)) and (position() &lt;= number($rto))]">
          <xsl:value-of select="@orth"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="pos">
       <xsl:value-of select="$chunk_rules/cha:rule[@id = $rid]/cha:lhs/cha:W2/@pos"/>
      </xsl:attribute>
      <xsl:variable name="cType" select="$input/*[number($rto)]/@cType"/>
      <xsl:if test="$cType">
        <xsl:attribute name="cType">
          <xsl:value-of select="$cType"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:variable name="cForm" select="$input/*[number($rto)]/@cForm"/>
      <xsl:if test="$cForm">
        <xsl:attribute name="cForm">
          <xsl:value-of select="$cForm"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:for-each select="$input/*[(position() >= number($rfrom)) and (position() &lt;= number($rto))]">
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </cha:W2>
  </xsl:template>

<!-- B,I,EによるW2の作成 -->

  <xsl:template match="cha:W1[@w2Chunk = 'B']" priority="10" mode="chunker">
    <xsl:variable name="nthB" select="count(preceding-sibling::cha:W1[@w2Chunk = 'B']) + 1"/>
    <cha:W2>
      <xsl:for-each select="@*[starts-with(name(), 'w2_')]">
        <xsl:attribute name="{substring-after(name(), 'w2_')}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="." mode="delete-w2-info"/>
      <xsl:apply-templates select="following-sibling::cha:W1[(@w2Chunk = 'I') and (count(preceding-sibling::cha:W1[@w2Chunk = 'B']) = $nthB)]" mode="delete-w2-info"/>
      <xsl:apply-templates select="following-sibling::cha:W1[@w2Chunk = 'E'][1]" mode="delete-w2-info"/> 
    </cha:W2>
  </xsl:template>

  <xsl:template match="cha:W1" mode="delete-w2-info">
    <cha:W1>
      <xsl:for-each select="@*[not(starts-with(name(), 'w2'))]">
        <xsl:attribute name="{name()}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates/>
    </cha:W1>  
  </xsl:template>

  <xsl:template match="cha:W1[@w2Chunk = 'I']" priority="10" mode="chunker">
  </xsl:template>

  <xsl:template match="cha:W1[@w2Chunk = 'E']" priority="10" mode="chunker">
  </xsl:template>

</xsl:stylesheet>
