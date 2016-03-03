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

    long portletDisplayDDMTemplateId = PortletDisplayTemplateUtil.getPortletDisplayTemplateDDMTemplateId(displayStyleGroupId, displayStyle);
%>

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
        <div class="asset-categories-sorting">
            <liferay-ui:message key="portlet.categoriesNavigation.sorting.sortBy" />
            <%
                String field = ParamUtil.getString(request, "sortingField");
                String type = ParamUtil.getString(request, "sortingType");
                PortletURL portletURL = renderResponse.createRenderURL();

                portletURL.setParameter("categoryId", String.valueOf(ParamUtil.getLong(request, "categoryId")));
                portletURL.setParameter("sortingField", "create-date");
                if (field.equals("create-date") && type.equals("ASC")) {
                    portletURL.setParameter("sortingType", "DESC");
                } else {
                    portletURL.setParameter("sortingType", "ASC");
                }
            %>
            <a href="<%= HtmlUtil.escape(portletURL.toString()) %>"
               class="asset-categories-sorting-type
						<c:if test="<%= field.equals(\"create-date\") %>">active</c:if>
            <c:if test="<%= field.equals(\"create-date\") && type.equals(\"ASC\") %>">asc</c:if>
            <c:if test="<%= field.equals(\"create-date\") && type.equals(\"DESC\") %>">desc</c:if>
            "
            >
            <liferay-ui:message key="portlet.categoriesNavigation.sorting.date" />
            <c:if test="<%= field.equals(\"create-date\") && type.equals(\"ASC\") %>"><span class="icon-arrow-down"></span></c:if>
            <c:if test="<%= field.equals(\"create-date\") && type.equals(\"DESC\") %>"><span class="icon-arrow-up"></span></c:if>
            </a>
            <%
                portletURL.setParameter("sortingField", "priority");
                if (field.equals("priority") && type.equals("ASC")) {
                    portletURL.setParameter("sortingType", "DESC");
                } else {
                    portletURL.setParameter("sortingType", "ASC");
                }
            %>
            <a href="<%= HtmlUtil.escape(portletURL.toString()) %>"
               class="asset-categories-sorting-type
						<c:if test="<%= field.equals(\"priority\") %>">active</c:if>
            <c:if test="<%= field.equals(\"priority\") && type.equals(\"ASC\") %>">asc</c:if>
            <c:if test="<%= field.equals(\"priority\") && type.equals(\"DESC\") %>">desc</c:if>
            "
            >
            <liferay-ui:message key="portlet.categoriesNavigation.sorting.author" />
            <c:if test="<%= field.equals(\"priority\") && type.equals(\"ASC\") %>"><span class="icon-arrow-down"></span></c:if>
            <c:if test="<%= field.equals(\"priority\") && type.equals(\"DESC\") %>"><span class="icon-arrow-up"></span></c:if>
            </a>
            <style>
                .asset-categories-sorting {
                    padding-bottom: 10px;
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
        </div>
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
    </c:otherwise>
</c:choose>