<%@ taglib prefix="aui" uri="http://liferay.com/tld/aui" %>
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
String redirect = ParamUtil.getString(request, "redirect");
Boolean enableSorting = PrefsParamUtil.getBoolean(portletPreferences, request, "enableSorting");
String dateForSorting = PrefsParamUtil.getString(portletPreferences, request, "dateForSorting", "");
String vocabularyIdSorting = PrefsParamUtil.getString(portletPreferences, request, "vocabularyIdSorting", "");

%>

<liferay-portlet:actionURL portletConfiguration="true" var="configurationURL" />

<aui:form action="<%= configurationURL %>" method="post" name="fm" onSubmit='<%= "event.preventDefault(); " + renderResponse.getNamespace() + "saveConfiguration();" %>'>
	<aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= Constants.UPDATE %>" />
	<aui:input name="redirect" type="hidden" value="<%= redirect %>" />

	<aui:fieldset>
		<aui:select label="vocabularies" name="preferences--allAssetVocabularies--">
			<aui:option label="all" selected="<%= allAssetVocabularies %>" value="<%= true %>" />
			<aui:option label="filter[action]" selected="<%= !allAssetVocabularies %>" value="<%= false %>" />
		</aui:select>


		<%
			Set<Long> availableAssetVocabularyIdsSet = SetUtil.fromArray(availableAssetVocabularyIds);
		%>


		<aui:input name="preferences--assetVocabularyIds--" type="hidden" />

		<%

		// Left list

		List<KeyValuePair> typesLeftList = new ArrayList<KeyValuePair>();

		for (long assetVocabularyId : assetVocabularyIds) {
			try {
				AssetVocabulary assetVocabulary = AssetVocabularyLocalServiceUtil.getVocabulary(assetVocabularyId);

				assetVocabulary = assetVocabulary.toEscapedModel();

				typesLeftList.add(new KeyValuePair(String.valueOf(assetVocabularyId), _getTitle(assetVocabulary, themeDisplay)));
			}
			catch (NoSuchVocabularyException nsve) {
			}
		}

		// Right list

		List<KeyValuePair> typesRightList = new ArrayList<KeyValuePair>();

		Arrays.sort(assetVocabularyIds);

		for (long assetVocabularyId : availableAssetVocabularyIdsSet) {
			if (Arrays.binarySearch(assetVocabularyIds, assetVocabularyId) < 0) {
				AssetVocabulary assetVocabulary = AssetVocabularyLocalServiceUtil.getVocabulary(assetVocabularyId);

				assetVocabulary = assetVocabulary.toEscapedModel();

				typesRightList.add(new KeyValuePair(String.valueOf(assetVocabularyId), _getTitle(assetVocabulary, themeDisplay)));
			}
		}

		typesRightList = ListUtil.sort(typesRightList, new KeyValuePairComparator(false, true));
		%>

		<div class="<%= allAssetVocabularies ? "hide" : "" %>" id="<portlet:namespace />assetVocabulariesBoxes">
			<liferay-ui:input-move-boxes
				leftBoxName="currentAssetVocabularyIds"
				leftList="<%= typesLeftList %>"
				leftReorder="true"
				leftTitle="current"
				rightBoxName="availableAssetVocabularyIds"
				rightList="<%= typesRightList %>"
				rightTitle="available"
			/>
		</div>

		<div class="display-template">

			<%
			TemplateHandler templateHandler = TemplateHandlerRegistryUtil.getTemplateHandler(AssetCategory.class.getName());
			%>

			<liferay-ui:ddm-template-selector
				classNameId="<%= PortalUtil.getClassNameId(templateHandler.getClassName()) %>"
				displayStyle="<%= displayStyle %>"
				displayStyleGroupId="<%= displayStyleGroupId %>"
				refreshURL="<%= currentURL %>"
				showEmptyOption="<%= true %>"
			/>
		</div>

		<aui:input label="enable-sorting" name="preferences--enableSorting--" type="checkbox" value="<%= enableSorting %>" />

		<aui:select inlineField="<%= true %>" inlineLabel="left" label="date-for-sorting" name="preferences--dateForSorting--">
			<aui:option label="create-date" selected='<%= dateForSorting.equals("createDate") %>' value="createDate" />
			<aui:option label="modified-date" selected='<%= dateForSorting.equals("modifiedDate") %>' value="modifiedDate" />
			<aui:option label="publish-date" selected='<%= dateForSorting.equals("publishDate") %>' value="publishDate" />
			<aui:option label="expiration-date" selected='<%= dateForSorting.equals("expirationDate") %>' value="expirationDate" />
		</aui:select>

		<aui:select label="vocabulary-sorting" name="preferences--vocabularyIdSorting--">

			<%
				for (long id:availableAssetVocabularyIdsSet) {
			%>
			<aui:option label="<%= _getTitle(AssetVocabularyLocalServiceUtil.getVocabulary(id),themeDisplay)%>" value="<%= id%>" selected="<%= vocabularyIdSorting.equals(String.valueOf(id))%>" />
			<%
				}
			%>


		</aui:select>


	</aui:fieldset>

	<aui:button-row>
		<aui:button type="submit" />
	</aui:button-row>
</aui:form>

<aui:script>
	Liferay.provide(
		window,
		'<portlet:namespace />saveConfiguration',
		function() {
			if (document.<portlet:namespace />fm.<portlet:namespace />assetVocabularyIds) {
				document.<portlet:namespace />fm.<portlet:namespace />assetVocabularyIds.value = Liferay.Util.listSelect(document.<portlet:namespace />fm.<portlet:namespace />currentAssetVocabularyIds);
			}

			submitForm(document.<portlet:namespace />fm);
		},
		['liferay-util-list-fields']
	);

	Liferay.Util.toggleSelectBox('<portlet:namespace />allAssetVocabularies', 'false', '<portlet:namespace />assetVocabulariesBoxes');
</aui:script>

<%!
private String _getTitle(AssetVocabulary assetVocabulary, ThemeDisplay themeDisplay) {
	String title = assetVocabulary.getTitle(themeDisplay.getLanguageId());

	if (assetVocabulary.getGroupId() == themeDisplay.getCompanyGroupId()) {
		title += " (" + LanguageUtil.get(themeDisplay.getLocale(), "global") + ")";
	}

	return title;
}
%>