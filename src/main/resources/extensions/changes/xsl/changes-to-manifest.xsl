<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns="http://pear.php.net/dtd/package-2.0"
                xmlns:pear="http://pear.php.net/dtd/package-2.0"
                xmlns:changes="http://maven.apache.org/changes/1.0.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://pear.php.net/dtd/package-2.0 http://pear.php.net/dtd/package-2.0.xsd
                                    http://maven.apache.org/changes/1.0.0 http://maven.apache.org/plugins/maven-changes-plugin/xsd/changes-1.0.0.xsd">

    <xsl:output method="xml"
                indent="yes"
                standalone="yes"
                version="1.0"
                encoding="UTF-8"
                media-type="text/xml"/>
    
    <xsl:include href="rst.xsl" />

    <xsl:param name="changes.stability" select="'stable'" />
    <xsl:param name="changes.file" select="''" />

    <xsl:variable name="nl">
        <xsl:text>
</xsl:text>
    </xsl:variable>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <!--
        Replace existing changelog
    -->
    <xsl:template match="pear:changelog">
        <xsl:apply-templates select="document($changes.file)//changes:body" />
    </xsl:template>

    <!--
        
    -->
    <xsl:template match="changes:body">
        <xsl:if test="count(*) &gt; 0">
            <xsl:element name="changelog">
                <xsl:value-of select="$nl" />
                <xsl:apply-templates select="*">
                    <xsl:sort select="@date" order="descending" />
                </xsl:apply-templates>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="changes:release">
        <xsl:element name="release">
            <xsl:element name="date">
                <xsl:value-of select="@date" />
            </xsl:element>
            <xsl:element name="stability">
                <xsl:element name="release">
                    <xsl:value-of select="$changes.stability" />
                </xsl:element>
                <xsl:element name="api">
                    <xsl:value-of select="$changes.stability" />
                </xsl:element>
            </xsl:element>
            <xsl:element name="version">
                <xsl:element name="release">
                    <xsl:value-of select="@version" />
                </xsl:element>
                <xsl:element name="api">
                    <xsl:value-of select="@version" />
                </xsl:element>
            </xsl:element>
            <xsl:element name="notes">
                <xsl:value-of select="$nl" />
                <xsl:call-template name="wrap">
                    <xsl:with-param name="string" select="@description" />
                </xsl:call-template>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
