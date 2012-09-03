<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output indent="yes"
                method="xml"
                omit-xml-declaration="no"
                encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:element name="project">
            <xsl:attribute name="name">
                <xsl:text>ant-build-commons-archtype-multiple-project</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="basedir">
                <xsl:text>.</xsl:text>
            </xsl:attribute>

            <xsl:element name="property">
                <xsl:attribute name="name">
                    <xsl:text>subproject.basedir</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="value">
                    <xsl:text>${basedir}</xsl:text>
                </xsl:attribute>
            </xsl:element>

            <xsl:apply-templates select="//target[substring(@name, 1, 1) != '-' and substring(@name, 1, 1) != '~']" />
        </xsl:element>

    </xsl:template>

    <xsl:template match="//target">
        <xsl:element name="target">
            <xsl:attribute name="name">
                <xsl:value-of select="@name" />
            </xsl:attribute>
            <xsl:if test="@description">
                <xsl:attribute name="description">
                    <xsl:value-of select="@description" />
                </xsl:attribute>
            </xsl:if>
            <xsl:element name="subant">
                <xsl:attribute name="target">
                    <xsl:value-of select="@name" />
                </xsl:attribute>
                <xsl:attribute name="inheritall">
                    <xsl:text>true</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="inheritrefs">
                    <xsl:text>true</xsl:text>
                </xsl:attribute>
                <xsl:element name="fileset">
                    <xsl:attribute name="dir">
                        <xsl:text>${subproject.basedir}</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="includes">
                        <xsl:text>*/build.xml</xsl:text>
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
