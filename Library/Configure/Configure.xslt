<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8"
                indent="yes"
                method="xml" />

    <!--
        Variables filled by ANT call
    -->
    <xsl:param name="ant.project.name" select="'abc:configured:project'" />
    <xsl:param name="ant.basedir" />

    <!--
        Basic Document Transformations
    -->
    <xsl:template match="/">
        <project name="{$ant.project.name}"
                 basedir="{$ant.basedir}"
                 default="verify">
            <xsl:apply-templates select="/abc/project" />
        </project>
    </xsl:template>

    <xsl:template match="/abc/project">
        <xsl:variable name="profile.enabled">
            <xsl:choose>
                <xsl:when test="starts-with(@name, 'abc:') and not(starts-with(@name, 'abc:base:'))">
                    <xsl:call-template name="profile.enabled">
                        <xsl:with-param name="profile.name">
                            <xsl:call-template name="profile.from.project.name">
                                <xsl:with-param name="project.name"
                                                select="@name" />
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>true</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$profile.enabled = 'true'">
            <xsl:copy-of select="node()" />
        </xsl:if>
    </xsl:template>

    <!--
        Utillity Functions
    -->
    <xsl:template name="profile.from.project.name">
        <xsl:param name="project.name" />
        <xsl:value-of select="concat('profile.', translate(substring-after($project.name, 'abc:'), ':', '.'))" />
    </xsl:template>

    <xsl:template name="profile.enabled">
        <xsl:param name="profile.name" />

        <xsl:choose>
            <xsl:when test="/abc/properties/property[@name = $profile.name]">
                <xsl:choose>
                    <xsl:when test="/abc/properties/property[@name = $profile.name][@value = 'enabled']">
                        <xsl:text>true</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>false</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$profile.name != 'profile'">
                <xsl:call-template name="profile.enabled">
                    <xsl:with-param name="profile.name">
                        <xsl:call-template name="profile.get.parent">
                            <xsl:with-param name="profile.name"
                                            select="$profile.name" />
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="profile.get.parent">
        <xsl:param name="profile.name" />

        <xsl:if test="contains($profile.name, '.')">
            <xsl:value-of select="substring-before($profile.name, '.')" />
            <xsl:if test="contains(substring-after($profile.name, '.'), '.')">
                <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:call-template name="profile.get.parent">
                <xsl:with-param name="profile.name"
                                select="substring-after($profile.name, '.')" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>