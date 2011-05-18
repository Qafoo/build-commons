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