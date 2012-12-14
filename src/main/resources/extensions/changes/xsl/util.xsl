<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template name="dirname">
        <xsl:param name="path" />
        <xsl:if test="contains($path, '/')">
            <xsl:value-of select="concat(substring-before($path, '/'), '/')" />
            <xsl:call-template name="dirname">
                <xsl:with-param name="path"
                                select="substring-after($path, '/')" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
