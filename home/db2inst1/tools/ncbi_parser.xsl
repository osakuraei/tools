<?xml version='1.0'  encoding="ISO-8859-1" ?>
<xsl:stylesheet
    xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    version='1.0'
    >

<xsl:output method="text"/>

<xsl:template match="/">
<xsl:apply-templates select="Entrezgene-Set"/>
</xsl:template>

<xsl:template match="Entrezgene-Set">
<xsl:apply-templates select="Entrezgene"/>
</xsl:template>

<xsl:template match="Entrezgene">
id	<xsl:value-of select="Entrezgene_track-info/Gene-track/Gene-track_geneid"/>
locus	<xsl:value-of select="Entrezgene_gene/Gene-ref/Gene-ref_locus"/>
[
<xsl:apply-templates select=".//Gene-commentary[Gene-commentary_heading='NCBI Reference Sequences (RefSeq)']//Gene-commentary_products/Gene-commentary[starts-with(Gene-commentary_accession,'NM_')]"  mode="product"/>
]
</xsl:template>

<xsl:template match="Gene-commentary" mode="product">
type	<xsl:value-of select="Gene-commentary_type/@value"/>
acn	<xsl:value-of select="Gene-commentary_accession"/>

</xsl:template>

</xsl:stylesheet>
