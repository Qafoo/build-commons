<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8"
                indent="yes"
                method="xml" />
    <xsl:param name="ant.project.name" select="'abc:configured:project'" />
    <xsl:param name="ant.basedir" />

    <xsl:template match="/">
        <project name="{$ant.project.name}"
                 basedir="{$ant.basedir}">
            <xsl:apply-templates select="/abc/project" />
        </project>
    </xsl:template>

    <xsl:template match="/abc/project">
        <xsl:choose>
            <xsl:when test=""
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>