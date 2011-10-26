<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template name="document-headline">
        <xsl:param name="headline" />

        <xsl:call-template name="line">
            <xsl:with-param name="length" select="string-length($headline)" />
        </xsl:call-template>
        <xsl:value-of select="$nl" />

        <xsl:value-of select="$headline" />
        <xsl:value-of select="$nl" />

        <xsl:call-template name="line">
            <xsl:with-param name="length" select="string-length($headline)" />
        </xsl:call-template>
        <xsl:value-of select="$nl" />
        <xsl:value-of select="$nl" />
    </xsl:template>

    <xsl:template name="section-headline">
        <xsl:param name="char" select="'='" />
        <xsl:param name="headline" />

        <xsl:value-of select="$headline" />
        <xsl:value-of select="$nl" />

        <xsl:call-template name="line">
            <xsl:with-param name="length" select="string-length($headline)" />
        </xsl:call-template>
        <xsl:value-of select="$nl" />
        <xsl:value-of select="$nl" />
    </xsl:template>

    <xsl:template name="wrap">
        <xsl:param name="string" select="''" />
        <xsl:param name="length" select="0" />
        <xsl:param name="maxlength" select="70" />
        <xsl:param name="indent" select="''" />

        <xsl:call-template name="wrap-string">
            <xsl:with-param name="string" select="normalize-space($string)" />
            <xsl:with-param name="length" select="$length" />
            <xsl:with-param name="maxlength" select="$maxlength" />
            <xsl:with-param name="indent" select="$indent" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="wrap-string">
        <xsl:param name="string" select="''" />
        <xsl:param name="length" select="0" />
        <xsl:param name="maxlength" select="70" />
        <xsl:param name="indent" select="''" />

        <xsl:variable name="word" select="substring-before($string, ' ')" />
        <xsl:variable name="newlength" select="$length + string-length($word)" />

        <xsl:choose>
            <xsl:when test="string-length($word) = 0">
                <xsl:if test="string-length($string) &gt; 0">
                    <xsl:if test="$length + string-length($string) &gt; $maxlength">
                        <xsl:value-of select="$nl" />
                        <xsl:value-of select="$indent" />
                    </xsl:if>
                    <xsl:value-of select="$string" />
                </xsl:if>
                <xsl:value-of select="$nl" />
            </xsl:when>
            <xsl:when test="$newlength &gt; $maxlength">
                <xsl:value-of select="$nl" />
                <xsl:value-of select="$indent" />
                <xsl:call-template name="wrap-string">
                    <xsl:with-param name="string" select="$string" />
                    <xsl:with-param name="length" select="string-length($indent)" />
                    <xsl:with-param name="maxlength" select="$maxlength" />
                    <xsl:with-param name="indent" select="$indent" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$word" />
                <xsl:text> </xsl:text>
                <xsl:call-template name="wrap-string">
                    <xsl:with-param name="string" select="substring-after($string, ' ')" />
                    <xsl:with-param name="length" select="$newlength + 1" />
                    <xsl:with-param name="maxlength" select="$maxlength" />
                    <xsl:with-param name="indent" select="$indent" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="line">
        <xsl:param name="char" select="'='" />
        <xsl:param name="offset" select="0" />
        <xsl:param name="length" select="0" />

        <xsl:if test="$offset &lt; $length">
            <xsl:value-of select="$char" />
            <xsl:call-template name="line">
                <xsl:with-param name="char" select="$char" />
                <xsl:with-param name="offset" select="$offset + 1" />
                <xsl:with-param name="length" select="$length" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
