<%--
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/portlet/asset_categories_navigation/init.jsp" %>

<%
Boolean enableSorting = PrefsParamUtil.getBoolean(portletPreferences, request, "enableSorting");
String dateForSorting = PrefsParamUtil.getString(portletPreferences, request, "dateForSorting", "");
String vocabularyIdSorting = PrefsParamUtil.getString(portletPreferences, request, "vocabularyIdSorting", "");
String portletId = portletDisplay.getRootPortletId();
String portletStorageKey = "categoriesNavigation_" + portletId + "_";

    long portletDisplayDDMTemplateId = PortletDisplayTemplateUtil.getPortletDisplayTemplateDDMTemplateId(displayStyleGroupId, displayStyle);
%>
<div class="categories-nav-container">
<c:choose>
    <c:when test="<%= portletDisplayDDMTemplateId > 0 %>">

        <%
            List<AssetVocabulary> ddmTemplateAssetVocabularies = new ArrayList<AssetVocabulary>();

            if (allAssetVocabularies) {
                ddmTemplateAssetVocabularies = assetVocabularies;
            }
            else {
                for (long assetVocabularyId : assetVocabularyIds) {
                    try {
                        ddmTemplateAssetVocabularies.add(AssetVocabularyServiceUtil.getVocabulary(assetVocabularyId));
                    }
                    catch (NoSuchVocabularyException nsve) {
                    }
                }
            }
        %>

        <%= PortletDisplayTemplateUtil.renderDDMTemplate(pageContext, portletDisplayDDMTemplateId, ddmTemplateAssetVocabularies) %>
    </c:when>
    <c:otherwise>

        <c:if test="<%= enableSorting %>">
            <div class="asset-categories-sorting-header partition-toggler-header btn">
                <liferay-ui:message key="portlet.categoriesNavigation.sorting" />
            </div>
            <div class="asset-categories-sorting toggler-content-collapsed">
                <liferay-ui:message key="portlet.categoriesNavigation.sorting.sortBy" />
                <%
                    String field = ParamUtil.getString(request, "sortingField");
                    String type = ParamUtil.getString(request, "sortingType");
                    PortletURL portletURL = renderResponse.createRenderURL();

                    portletURL.setParameter("categoryId", String.valueOf(ParamUtil.getLong(request, "categoryId")));
                    portletURL.setParameter("sortingField", dateForSorting);
                    if (field.equals(dateForSorting) && type.equals("ASC")) {
                        portletURL.setParameter("sortingType", "DESC");
                    } else {
                        portletURL.setParameter("sortingType", "ASC");
                    }
                %>
                <a href="<%= HtmlUtil.escape(portletURL.toString()) %>"
                    class="asset-categories-sorting-type
                            <c:if test="<%= field.equals(dateForSorting) %>">active</c:if>
                            <c:if test="<%= field.equals(dateForSorting) && type.equals(\"ASC\") %>">asc</c:if>
                            <c:if test="<%= field.equals(dateForSorting) && type.equals(\"DESC\") %>">desc</c:if>
                        "
                >
                    <liferay-ui:message key="portlet.categoriesNavigation.sorting.date" />
                    <c:if test="<%= field.equals(dateForSorting) && type.equals(\"ASC\") %>"><span class="icon-arrow-down"></span></c:if>
                    <c:if test="<%= field.equals(dateForSorting) && type.equals(\"DESC\") %>"><span class="icon-arrow-up"></span></c:if>
                </a>
                <%
                    portletURL.setParameter("sortingField", "lastName");
                    if (field.equals("lastName") && type.equals("ASC")) {
                        portletURL.setParameter("sortingType", "DESC");
                    } else {
                        portletURL.setParameter("sortingType", "ASC");
                    }
                %>
                <a href="<%= HtmlUtil.escape(portletURL.toString()) %>"
                    class="asset-categories-sorting-type
                            <c:if test="<%= field.equals(\"lastName\") %>">active</c:if>
                            <c:if test="<%= field.equals(\"lastName\") && type.equals(\"ASC\") %>">asc</c:if>
                            <c:if test="<%= field.equals(\"lastName\") && type.equals(\"DESC\") %>">desc</c:if>
                        "
                >
                <liferay-ui:message key="portlet.categoriesNavigation.sorting.author" />
                <c:if test="<%= field.equals(\"lastName\") && type.equals(\"ASC\") %>"><span class="icon-arrow-down"></span></c:if>
                <c:if test="<%= field.equals(\"lastName\") && type.equals(\"DESC\") %>"><span class="icon-arrow-up"></span></c:if>
                </a>
                <%
                    portletURL.setParameter("sortingField", "categoryName:"+vocabularyIdSorting);
                    if (field.startsWith("categoryName") && type.equals("ASC")) {
                        portletURL.setParameter("sortingType", "DESC");
                    } else {
                        portletURL.setParameter("sortingType", "ASC");
                    }
                %>
                <a href="<%= HtmlUtil.escape(portletURL.toString()) %>"
                   class="asset-categories-sorting-type
                            <c:if test="<%= field.startsWith(\"categoryName\") %>">active</c:if>
                            <c:if test="<%= field.startsWith(\"categoryName\") && type.equals(\"ASC\") %>">asc</c:if>
                            <c:if test="<%= field.startsWith(\"categoryName\") && type.equals(\"DESC\") %>">desc</c:if>
                        "
                >
                <liferay-ui:message key="portlet.categoriesNavigation.sorting.category" />
                <c:if test="<%= field.startsWith(\"categoryName\") && type.equals(\"ASC\") %>"><span class="icon-arrow-down"></span></c:if>
                <c:if test="<%= field.startsWith(\"categoryName\") && type.equals(\"DESC\") %>"><span class="icon-arrow-up"></span></c:if></a>
                <style>
                    .btn.partition-toggler-header {
                        display: block;
                        text-align: left;
                        margin-bottom: 10px;
                    }
                    .btn.partition-toggler-header.toggler-header-expanded {
                        text-decoration: none;
                        background-position: 0 -15px;
                        background-color: #eaeaea;
                        color: #333;
                    }
                    .asset-categories-sorting {
                        padding: 0 10px 10px;
                    }
                    .asset-categories-sorting-type {
                        margin-left: 8px;
                    }
                    .asset-categories-sorting-type.active {
                        padding: 2px 8px;
                        border-radius: 10px;
                        background: #e3e3e3;
                    }
                    .asset-categories-sorting-type.active:hover {
                        background: #ccc;
                        text-decoration: none;
                    }
                    .asset-categories-sorting-type .icon-arrow-down,
                    .asset-categories-sorting-type .icon-arrow-up {
                        font-size: 10px;
                    }
                </style>
                <aui:script use="aui-toggler">
                    new A.Toggler({
                        header: '.asset-categories-sorting-header',
                        content: '.asset-categories-sorting',
                        expanded: sessionStorage.<%= portletStorageKey %>sortingExpanded === "true"
                    }).on('expandedChange', function(event) {
                        console.log('sorting', event.newVal);
                        sessionStorage.<%= portletStorageKey %>sortingExpanded = event.newVal;
                    });

                    new A.Toggler({
                        header: '.asset-categories-filtering-header',
                        content: '.asset-categories-filtering',
                        expanded: sessionStorage.<%= portletStorageKey %>filteringExpanded === "true"
                    }).on('expandedChange', function(event) {
                        console.log('filtering', event.newVal);
                        sessionStorage.<%= portletStorageKey %>filteringExpanded = event.newVal;
                    });
                </aui:script>
            </div>
        </c:if>

        <c:if test="<%= enableSorting %>">
            <div class="asset-categories-filtering-header partition-toggler-header btn">
                <liferay-ui:message key="portlet.categoriesNavigation.filtering" />
            </div>
            <div class="asset-categories-filtering toggler-content-collapsed">
        </c:if>

                <c:choose>
                    <c:when test="<%= allAssetVocabularies %>">
                        <liferay-ui:asset-categories-navigation
                                hidePortletWhenEmpty="<%= true %>"
                                />
                    </c:when>
                    <c:otherwise>
                        <liferay-ui:asset-categories-navigation
                                hidePortletWhenEmpty="<%= true %>"
                                vocabularyIds="<%= assetVocabularyIds %>"
                                />
                    </c:otherwise>
                </c:choose>

        <c:if test="<%= enableSorting %>">
            </div>
        </c:if>

    </c:otherwise>
</c:choose>
</div>
