<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : match.xsl
    Created on : 25. März 2013, 16:54
    Author     : manu
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml"
                indent="yes"/>

    <xsl:template match="/">
        <project>
            <xsl:apply-templates select="/abc/project" />
        </project>
    </xsl:template>
    
    <xsl:template match="/abc/project">
        <xsl:variable name="profile.enabled">
            <xsl:choose>
                <xsl:when test="starts-with(@name, 'abc:')">
                    <xsl:call-template name="profile.enabled">
                        <xsl:with-param name="profile.name">
                            <xsl:call-template name="profile.from.project.name">
                                <xsl:with-param name="project.name" select="@name" />
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>1</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$profile.enabled = 1">
            <target name="{@name}" />
        </xsl:if>
        
    </xsl:template>
    
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
                        <xsl:text>1</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>0</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$profile.name != 'profile'">
                <xsl:call-template name="profile.enabled">
                    <xsl:with-param name="profile.name">
                        <xsl:call-template name="profile.get.parent">
                            <xsl:with-param name="profile.name" select="$profile.name" />
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
                <xsl:with-param name="profile.name" select="substring-after($profile.name, '.')" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
