<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
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

<%@ include file="/init.jsp" %>

<%
Group group = (Group)request.getAttribute("site.group");
Group liveGroup = (Group)request.getAttribute("site.liveGroup");
LayoutSetPrototype layoutSetPrototype = (LayoutSetPrototype)request.getAttribute("site.layoutSetPrototype");
boolean showPrototypes = GetterUtil.getBoolean(request.getAttribute("site.showPrototypes"));

long parentGroupId = ParamUtil.getLong(request, "parentGroupSearchContainerPrimaryKeys", (group != null) ? group.getParentGroupId() : GroupConstants.DEFAULT_PARENT_GROUP_ID);

if (parentGroupId <= 0) {
	parentGroupId = GroupConstants.DEFAULT_PARENT_GROUP_ID;

	if (liveGroup != null) {
		parentGroupId = liveGroup.getParentGroupId();
	}
}

Group parentGroup = null;

if ((group == null) && (parentGroupId == GroupConstants.DEFAULT_PARENT_GROUP_ID) && !permissionChecker.isCompanyAdmin()) {
	List<Group> manageableGroups = new ArrayList<Group>();

	for (Group curGroup : user.getGroups()) {
		if (GroupPermissionUtil.contains(permissionChecker, curGroup, ActionKeys.MANAGE_SUBGROUPS)) {
			manageableGroups.add(curGroup);
		}
	}

	if (manageableGroups.size() == 1) {
		Group manageableGroup = manageableGroups.get(0);

		parentGroupId = manageableGroup.getGroupId();
	}
}

if (parentGroupId != GroupConstants.DEFAULT_PARENT_GROUP_ID) {
	parentGroup = GroupLocalServiceUtil.fetchGroup(parentGroupId);
}

List<LayoutSetPrototype> layoutSetPrototypes = LayoutSetPrototypeServiceUtil.search(company.getCompanyId(), Boolean.TRUE, null);

LayoutSet privateLayoutSet = null;
LayoutSetPrototype privateLayoutSetPrototype = null;
boolean privateLayoutSetPrototypeLinkEnabled = true;

LayoutSet publicLayoutSet = null;
LayoutSetPrototype publicLayoutSetPrototype = null;
boolean publicLayoutSetPrototypeLinkEnabled = true;

if (showPrototypes && (group != null)) {
	try {
		privateLayoutSet = LayoutSetLocalServiceUtil.getLayoutSet(group.getGroupId(), true);

		privateLayoutSetPrototypeLinkEnabled = privateLayoutSet.isLayoutSetPrototypeLinkEnabled();

		String layoutSetPrototypeUuid = privateLayoutSet.getLayoutSetPrototypeUuid();

		if (Validator.isNotNull(layoutSetPrototypeUuid)) {
			privateLayoutSetPrototype = LayoutSetPrototypeLocalServiceUtil.getLayoutSetPrototypeByUuidAndCompanyId(layoutSetPrototypeUuid, company.getCompanyId());
		}
	}
	catch (Exception e) {
	}

	try {
		publicLayoutSet = LayoutSetLocalServiceUtil.getLayoutSet(group.getGroupId(), false);

		publicLayoutSetPrototypeLinkEnabled = publicLayoutSet.isLayoutSetPrototypeLinkEnabled();

		String layoutSetPrototypeUuid = publicLayoutSet.getLayoutSetPrototypeUuid();

		if (Validator.isNotNull(layoutSetPrototypeUuid)) {
			publicLayoutSetPrototype = LayoutSetPrototypeLocalServiceUtil.getLayoutSetPrototypeByUuidAndCompanyId(layoutSetPrototypeUuid, company.getCompanyId());
		}
	}
	catch (Exception e) {
	}
}

UnicodeProperties typeSettingsProperties = null;

if (liveGroup != null) {
	typeSettingsProperties = liveGroup.getTypeSettingsProperties();
}
else if (group != null) {
	typeSettingsProperties = group.getTypeSettingsProperties();
}
%>

<liferay-ui:error-marker key="errorSection" value="details" />

<aui:model-context bean="<%= liveGroup %>" model="<%= Group.class %>" />

<liferay-ui:error exception="<%= DuplicateGroupException.class %>" message="please-enter-a-unique-name" />
<liferay-ui:error exception="<%= GroupInheritContentException.class %>" message="this-site-cannot-inherit-content-from-its-parent-site" />

<liferay-ui:error exception="<%= GroupKeyException.class %>">
	<p>
		<liferay-ui:message arguments="<%= new String[] {SiteConstants.NAME_LABEL, SiteConstants.getNameGeneralRestrictions(locale), SiteConstants.NAME_RESERVED_WORDS} %>" key="the-x-cannot-be-x-or-a-reserved-word-such-as-x" />
	</p>

	<p>
		<liferay-ui:message arguments="<%= new String[] {SiteConstants.NAME_LABEL, SiteConstants.NAME_INVALID_CHARACTERS} %>" key="the-x-cannot-contain-the-following-invalid-characters-x" />
	</p>
</liferay-ui:error>

<liferay-ui:error exception="<%= GroupParentException.MustNotBeOwnParent.class %>" message="the-site-cannot-be-its-own-parent-site" />
<liferay-ui:error exception="<%= GroupParentException.MustNotHaveChildParent.class %>" message="the-site-cannot-have-a-child-as-its-parent-site" />
<liferay-ui:error exception="<%= GroupParentException.MustNotHaveStagingParent.class %>" message="the-site-cannot-have-a-staging-site-as-its-parent-site" />
<liferay-ui:error exception="<%= PendingBackgroundTaskException.class %>" message="the-site-cannot-be-deleted-because-it-has-background-tasks-in-progress" />
<liferay-ui:error exception="<%= RequiredGroupException.MustNotDeleteCurrentGroup.class %>" message="the-site-cannot-be-deleted-or-deactivated-because-you-are-accessing-the-site" />
<liferay-ui:error exception="<%= RequiredGroupException.MustNotDeleteGroupThatHasChild.class %>" message="you-cannot-delete-sites-that-have-subsites" />
<liferay-ui:error exception="<%= RequiredGroupException.MustNotDeleteSystemGroup.class %>" message="the-site-cannot-be-deleted-or-deactivated-because-it-is-a-required-system-site" />

<liferay-ui:error key="resetMergeFailCountAndMerge" message="unable-to-reset-the-failure-counter-and-propagate-the-changes" />

<c:choose>
	<c:when test="<%= (liveGroup != null) && liveGroup.isOrganization() %>">
		<aui:input helpMessage="the-name-of-this-site-cannot-be-edited-because-it-belongs-to-an-organization" name="name" type="resource" value="<%= liveGroup.getDescriptiveName(locale) %>" />
	</c:when>
	<c:when test="<%= (liveGroup == null) || (!liveGroup.isCompany() && !PortalUtil.isSystemGroup(liveGroup.getGroupKey())) %>">
		<aui:input autoFocus="<%= windowState.equals(WindowState.MAXIMIZED) %>" name="name" />
	</c:when>
</c:choose>

<aui:input name="description" />

<c:if test="<%= liveGroup != null %>">
	<aui:input name="siteId" type="resource" value="<%= String.valueOf(liveGroup.getGroupId()) %>" />
</c:if>

<c:if test="<%= (group == null) || !group.isCompany() %>">
	<aui:input name="active" type="toggle-switch" value="<%= (group == null) ? true : group.isActive() %>" />
</c:if>

<c:if test="<%= (parentGroupId != GroupConstants.DEFAULT_PARENT_GROUP_ID) && PropsValues.SITES_SHOW_INHERIT_CONTENT_SCOPE_FROM_PARENT_SITE %>">

	<%
	boolean disabled = false;

	if ((parentGroup != null) && parentGroup.isInheritContent()) {
		disabled = true;
	}
	%>

	<aui:input disabled="<%= disabled %>" helpMessage='<%= disabled ? "this-site-cannot-inherit-the-content-from-its-parent-site-since-the-parent-site-is-already-inheriting-the-content-from-its-parent" : StringPool.BLANK %>' name="inheritContent" value="<%= false %>" />
</c:if>

<h3><liferay-ui:message key="membership-options" /></h3>

<c:if test="<%= (group == null) || !group.isCompany() %>">
	<aui:select label="membership-type" name="type">
		<aui:option label="open" value="<%= GroupConstants.TYPE_SITE_OPEN %>" />
		<aui:option label="restricted" value="<%= GroupConstants.TYPE_SITE_RESTRICTED %>" />
		<aui:option label="private" value="<%= GroupConstants.TYPE_SITE_PRIVATE %>" />
	</aui:select>

	<%
	boolean manualMembership = true;

	if (liveGroup != null) {
		manualMembership = GetterUtil.getBoolean(liveGroup.isManualMembership(), true);
	}
	%>

	<aui:input label="allow-manual-membership-management" name="manualMembership" type="toggle-switch" value="<%= manualMembership %>" />
</c:if>

<%
boolean disableLayoutSetPrototypeInput = false;

if ((group != null) && !LanguageUtil.isInheritLocales(group.getGroupId())) {
	disableLayoutSetPrototypeInput = true;
}

boolean hasUnlinkLayoutSetPrototypePermission = PortalPermissionUtil.contains(permissionChecker, ActionKeys.UNLINK_LAYOUT_SET_PROTOTYPE);
%>

<c:if test="<%= (group == null) || !group.isCompany() %>">
	<aui:fieldset>
		<c:choose>
			<c:when test="<%= showPrototypes && ((group != null) || (!layoutSetPrototypes.isEmpty() && (layoutSetPrototype == null))) %>">
				<h3><liferay-ui:message key="pages" /></h3>

				<liferay-ui:panel-container extended="<%= false %>">
					<liferay-ui:panel collapsible="<%= true %>" defaultState='<%= ((group != null) && (group.getPublicLayoutsPageCount() > 0)) ? "open" : "closed" %>' title="public-pages">
						<c:choose>
							<c:when test="<%= ((group == null) || ((publicLayoutSetPrototype == null) && (group.getPublicLayoutsPageCount() == 0))) && !layoutSetPrototypes.isEmpty() %>">
								<c:if test="<%= disableLayoutSetPrototypeInput %>">
									<div class="alert alert-info">
										<liferay-ui:message key="you-cannot-apply-a-site-template-because-you-modified-the-display-settings-of-this-site" />
									</div>
								</c:if>

								<aui:select disabled="<%= disableLayoutSetPrototypeInput %>" helpMessage="site-templates-with-an-incompatible-application-adapter-are-disabled" label="site-template" name="publicLayoutSetPrototypeId">
									<aui:option label="none" selected="<%= true %>" value="" />

									<%
									for (LayoutSetPrototype curLayoutSetPrototype : layoutSetPrototypes) {
										UnicodeProperties settingsProperties = curLayoutSetPrototype.getSettingsProperties();

										String servletContextName = settingsProperties.getProperty("customJspServletContextName", StringPool.BLANK);
									%>

										<aui:option data-servletContextName="<%= servletContextName %>" value="<%= curLayoutSetPrototype.getLayoutSetPrototypeId() %>"><%= HtmlUtil.escape(curLayoutSetPrototype.getName(locale)) %></aui:option>

									<%
									}
									%>

								</aui:select>

								<c:if test="<%= (group == null) || !group.isStaged() %>">
									<c:choose>
										<c:when test="<%= hasUnlinkLayoutSetPrototypePermission %>">
											<div class="hide" id="<portlet:namespace />publicLayoutSetPrototypeIdOptions">
												<c:if test="<%= disableLayoutSetPrototypeInput %>">
													<div class="alert alert-info">
														<liferay-ui:message key="you-cannot-enable-the-propagation-of-changes-because-you-modified-the-display-settings-of-this-site" />
													</div>
												</c:if>

												<aui:input disabled="<%= disableLayoutSetPrototypeInput %>" helpMessage="enable-propagation-of-changes-from-the-site-template-help" label="enable-propagation-of-changes-from-the-site-template" name="publicLayoutSetPrototypeLinkEnabled" type="toggle-switch" value="<%= publicLayoutSetPrototypeLinkEnabled %>" />
											</div>
										</c:when>
										<c:otherwise>
											<aui:input name="publicLayoutSetPrototypeLinkEnabled" type="hidden" value="<%= true %>" />
										</c:otherwise>
									</c:choose>
								</c:if>
							</c:when>
							<c:otherwise>
								<c:if test="<%= group != null %>">
									<c:choose>
										<c:when test="<%= group.getPublicLayoutsPageCount() > 0 %>">
											<aui:a href="<%= group.getDisplayURL(themeDisplay, false) %>" label="open-public-pages" target="_blank" />
										</c:when>
										<c:otherwise>
											<liferay-ui:message key="this-site-does-not-have-any-public-pages" />
										</c:otherwise>
									</c:choose>

									<c:choose>
										<c:when test="<%= (publicLayoutSetPrototype != null) && !group.isStaged() && hasUnlinkLayoutSetPrototypePermission %>">
											<c:if test="<%= disableLayoutSetPrototypeInput %>">
												<div class="alert alert-info">
													<liferay-ui:message key="you-cannot-enable-the-propagation-of-changes-because-you-modified-the-display-settings-of-this-site" />
												</div>
											</c:if>

											<aui:input disabled="<%= disableLayoutSetPrototypeInput %>" label='<%= LanguageUtil.format(request, "enable-propagation-of-changes-from-the-site-template-x", HtmlUtil.escape(publicLayoutSetPrototype.getName(locale)), false) %>' name="publicLayoutSetPrototypeLinkEnabled" type="toggle-switch" value="<%= publicLayoutSetPrototypeLinkEnabled %>" />

											<div class='<%= publicLayoutSetPrototypeLinkEnabled ? "" : "hide" %>' id="<portlet:namespace/>publicLayoutSetPrototypeMergeAlert">

												<%
												request.setAttribute("edit_layout_set_prototype.jsp-groupId", String.valueOf(group.getGroupId()));
												request.setAttribute("edit_layout_set_prototype.jsp-layoutSet", publicLayoutSet);
												request.setAttribute("edit_layout_set_prototype.jsp-layoutSetPrototype", publicLayoutSetPrototype);
												request.setAttribute("edit_layout_set_prototype.jsp-redirect", currentURL);
												%>

												<liferay-util:include page="/layout_set_merge_alert.jsp" servletContext="<%= application %>" />
											</div>
										</c:when>
										<c:when test="<%= publicLayoutSetPrototype != null %>">
											<liferay-ui:message arguments="<%= new Object[] {HtmlUtil.escape(publicLayoutSetPrototype.getName(locale))} %>" key="these-pages-are-linked-to-site-template-x" translateArguments="<%= false %>" />

											<aui:input name="publicLayoutSetPrototypeLinkEnabled" type="hidden" value="<%= publicLayoutSetPrototypeLinkEnabled %>" />
										</c:when>
									</c:choose>
								</c:if>
							</c:otherwise>
						</c:choose>
					</liferay-ui:panel>
					<liferay-ui:panel collapsible="<%= true %>" defaultState='<%= ((group != null) && (group.getPrivateLayoutsPageCount() > 0)) ? "open" : "closed" %>' title="private-pages">
						<c:choose>
							<c:when test="<%= ((group == null) || ((privateLayoutSetPrototype == null) && (group.getPrivateLayoutsPageCount() == 0))) && !layoutSetPrototypes.isEmpty() %>">
								<c:if test="<%= disableLayoutSetPrototypeInput %>">
									<div class="alert alert-info">
										<liferay-ui:message key="you-cannot-apply-a-site-template-because-you-modified-the-display-settings-of-this-site" />
									</div>
								</c:if>

								<aui:select disabled="<%= disableLayoutSetPrototypeInput %>" helpMessage="site-templates-with-an-incompatible-application-adapter-are-disabled" label="site-template" name="privateLayoutSetPrototypeId">
									<aui:option label="none" selected="<%= true %>" value="" />

									<%
									for (LayoutSetPrototype curLayoutSetPrototype : layoutSetPrototypes) {
										UnicodeProperties settingsProperties = curLayoutSetPrototype.getSettingsProperties();

										String servletContextName = settingsProperties.getProperty("customJspServletContextName", StringPool.BLANK);
									%>

										<aui:option data-servletContextName="<%= servletContextName %>" value="<%= curLayoutSetPrototype.getLayoutSetPrototypeId() %>"><%= HtmlUtil.escape(curLayoutSetPrototype.getName(locale)) %></aui:option>

									<%
									}
									%>

								</aui:select>

								<c:if test="<%= (group == null) || !group.isStaged() %>">
									<c:choose>
										<c:when test="<%= hasUnlinkLayoutSetPrototypePermission %>">
											<div class="hide" id="<portlet:namespace />privateLayoutSetPrototypeIdOptions">
												<c:if test="<%= disableLayoutSetPrototypeInput %>">
													<div class="alert alert-info">
														<liferay-ui:message key="you-cannot-enable-the-propagation-of-changes-because-you-modified-the-display-settings-of-this-site" />
													</div>
												</c:if>

												<aui:input disabled="<%= disableLayoutSetPrototypeInput %>" helpMessage="enable-propagation-of-changes-from-the-site-template-help" label="enable-propagation-of-changes-from-the-site-template" name="privateLayoutSetPrototypeLinkEnabled" type="toggle-switch" value="<%= privateLayoutSetPrototypeLinkEnabled %>" />
											</div>
										</c:when>
										<c:otherwise>
											<aui:input name="privateLayoutSetPrototypeLinkEnabled" type="hidden" value="<%= true %>" />
										</c:otherwise>
									</c:choose>
								</c:if>
							</c:when>
							<c:otherwise>
								<c:if test="<%= group != null %>">
									<c:choose>
										<c:when test="<%= group.getPrivateLayoutsPageCount() > 0 %>">
											<aui:a href="<%= group.getDisplayURL(themeDisplay, true) %>" label="open-private-pages" target="_blank" />
										</c:when>
										<c:otherwise>
											<liferay-ui:message key="this-site-does-not-have-any-private-pages" />
										</c:otherwise>
									</c:choose>

									<c:choose>
										<c:when test="<%= (privateLayoutSetPrototype != null) && !group.isStaged() && hasUnlinkLayoutSetPrototypePermission %>">
											<c:if test="<%= disableLayoutSetPrototypeInput %>">
												<div class="alert alert-info">
													<liferay-ui:message key="you-cannot-enable-the-propagation-of-changes-because-you-modified-the-display-settings-of-this-site" />
												</div>
											</c:if>

											<aui:input disabled="<%= disableLayoutSetPrototypeInput %>" label='<%= LanguageUtil.format(request, "enable-propagation-of-changes-from-the-site-template-x", HtmlUtil.escape(privateLayoutSetPrototype.getName(locale)), false) %>' name="privateLayoutSetPrototypeLinkEnabled" type="toggle-switch" value="<%= privateLayoutSetPrototypeLinkEnabled %>" />

											<div class='<%= privateLayoutSetPrototypeLinkEnabled ? "" : "hide" %>' id="<portlet:namespace/>privateLayoutSetPrototypeMergeAlert">

												<%
												request.setAttribute("edit_layout_set_prototype.jsp-groupId", String.valueOf(group.getGroupId()));
												request.setAttribute("edit_layout_set_prototype.jsp-layoutSet", privateLayoutSet);
												request.setAttribute("edit_layout_set_prototype.jsp-layoutSetPrototype", privateLayoutSetPrototype);
												request.setAttribute("edit_layout_set_prototype.jsp-redirect", currentURL);
												%>

												<liferay-util:include page="/layout_set_merge_alert.jsp" servletContext="<%= application %>" />
											</div>
										</c:when>
										<c:when test="<%= privateLayoutSetPrototype != null %>">
											<liferay-ui:message arguments="<%= new Object[] {HtmlUtil.escape(privateLayoutSetPrototype.getName(locale))} %>" key="these-pages-are-linked-to-site-template-x" translateArguments="<%= false %>" />

											<aui:input name="privateLayoutSetPrototypeLinkEnabled" type="hidden" value="<%= privateLayoutSetPrototypeLinkEnabled %>" />
										</c:when>
									</c:choose>
								</c:if>
							</c:otherwise>
						</c:choose>
					</liferay-ui:panel>
				</liferay-ui:panel-container>

				<%
				Set<String> servletContextNames = CustomJspRegistryUtil.getServletContextNames();
				%>

				<c:if test="<%= servletContextNames.size() > 0 %>">
					<aui:fieldset label="configuration">

						<%
						String customJspServletContextName = StringPool.BLANK;

						if (typeSettingsProperties != null) {
							customJspServletContextName = GetterUtil.getString(typeSettingsProperties.get("customJspServletContextName"));
						}
						%>

						<aui:select helpMessage='<%= LanguageUtil.format(request, "application-adapter-help", "http://www.liferay.com/community/wiki/-/wiki/Main/Application+Adapters", false) %>' label="application-adapter" name="customJspServletContextName">
							<aui:option label="none" value="" />

							<%
							for (String servletContextName : servletContextNames) {
							%>

								<aui:option selected="<%= customJspServletContextName.equals(servletContextName) %>" value="<%= servletContextName %>"><%= CustomJspRegistryUtil.getDisplayName(servletContextName) %></aui:option>

							<%
							}
							%>

						</aui:select>
					</aui:fieldset>

					<aui:script sandbox="<%= true %>">
						var applicationAdapter = $('#<portlet:namespace />customJspServletContextName');

						if (applicationAdapter.length) {
							var publicPages = $('#<portlet:namespace />publicLayoutSetPrototypeId');
							var privatePages = $('#<portlet:namespace />privateLayoutSetPrototypeId');

							var toggleCompatibleSiteTemplates = function(event) {
								var siteTemplate = applicationAdapter.val();

								var options = $();

								options = options.add(publicPages.find('option[data-servletContextName]'));
								options = options.add(privatePages.find('option[data-servletContextName]'));

								options.prop('disabled', false);

								if (siteTemplate) {
									options.filter(':not([data-servletContextName=' + siteTemplate + '])').prop('disabled', true);
								}
							};

							applicationAdapter.on('change', toggleCompatibleSiteTemplates);

							toggleCompatibleSiteTemplates();
						}
					</aui:script>
				</c:if>
			</c:when>
			<c:when test="<%= layoutSetPrototype != null %>">
				<aui:fieldset label="pages">
					<aui:input name="layoutSetPrototypeId" type="hidden" value="<%= layoutSetPrototype.getLayoutSetPrototypeId() %>" />

					<aui:field-wrapper label="copy-as">
						<aui:input checked="<%= true %>" helpMessage='<%= LanguageUtil.format(request, "select-this-to-copy-the-pages-of-the-site-template-x-as-public-pages-for-this-site", HtmlUtil.escape(layoutSetPrototype.getName(locale)), false) %>' label="public-pages" name="layoutSetVisibility" type="radio" value="0" />
						<aui:input helpMessage='<%= LanguageUtil.format(request, "select-this-to-copy-the-pages-of-the-site-template-x-as-private-pages-for-this-site", HtmlUtil.escape(layoutSetPrototype.getName(locale)), false) %>' label="private-pages" name="layoutSetVisibility" type="radio" value="1" />
					</aui:field-wrapper>

					<c:choose>
						<c:when test="<%= hasUnlinkLayoutSetPrototypePermission %>">
							<aui:input helpMessage="enable-propagation-of-changes-from-the-site-template-help" label="enable-propagation-of-changes-from-the-site-template" name="layoutSetPrototypeLinkEnabled" type="toggle-switch" value="<%= true %>" />
						</c:when>
						<c:otherwise>
							<aui:input name="layoutSetPrototypeLinkEnabled" type="hidden" value="<%= true %>" />
						</c:otherwise>
					</c:choose>
				</aui:fieldset>
			</c:when>
		</c:choose>
	</aui:fieldset>

	<%
	List<Group> parentGroups = new ArrayList<Group>();

	if (parentGroup != null) {
		parentGroups.add(parentGroup);
	}
	%>

	<liferay-util:buffer var="removeGroupIcon">
		<liferay-ui:icon
			icon="times"
			markupView="lexicon"
			message="remove"
		/>
	</liferay-util:buffer>

	<h3><liferay-ui:message key="parent-site" /></h3>

	<liferay-ui:search-container
		headerNames="name,type,null"
		id="parentGroupSearchContainer"
	>
		<liferay-ui:search-container-results
			results="<%= parentGroups %>"
			total="<%= parentGroups.size() %>"
		/>

		<liferay-ui:search-container-row
			className="com.liferay.portal.model.Group"
			escapedModel="<%= true %>"
			keyProperty="groupId"
			modelVar="curGroup"
		>
			<portlet:renderURL var="rowURL">
				<portlet:param name="mvcPath" value="/edit_site.jsp" />
				<portlet:param name="groupId" value="<%= String.valueOf(curGroup.getGroupId()) %>" />
			</portlet:renderURL>

			<liferay-ui:search-container-column-text
				href="<%= rowURL %>"
				name="name"
				value="<%= HtmlUtil.escape(curGroup.getDescriptiveName(locale)) %>"
			/>

			<liferay-ui:search-container-column-text
				name="type"
				value="<%= LanguageUtil.get(request, curGroup.getTypeLabel()) %>"
			/>

			<liferay-ui:search-container-column-text
				cssClass="list-group-item-field"
			>
				<a class="modify-link" data-rowId="<%= curGroup.getGroupId() %>" href="javascript:;"><%= removeGroupIcon %></a>
			</liferay-ui:search-container-column-text>
		</liferay-ui:search-container-row>

		<liferay-ui:search-iterator markupView="lexicon" paginate="<%= false %>" />
	</liferay-ui:search-container>

	<aui:button-row>
		<aui:button cssClass="btn-lg modify-link" id="selectParentSiteLink" value="select" />
	</aui:button-row>

	<div class="<%= parentGroups.isEmpty() ? "membership-restriction-container hide" : "membership-restriction-container" %>" id="<portlet:namespace />membershipRestrictionContainer">

		<%
		boolean membershipRestriction = false;

		if ((liveGroup != null) && (liveGroup.getMembershipRestriction() == GroupConstants.MEMBERSHIP_RESTRICTION_TO_PARENT_SITE_MEMBERS)) {
			membershipRestriction = true;
		}
		%>

		<aui:input label="limit-membership-to-members-of-the-parent-site" name="membershipRestriction" type="toggle-switch" value="<%= membershipRestriction %>" />

		<%
		boolean breadcrumbShowParentGroups = true;

		if (typeSettingsProperties != null) {
			breadcrumbShowParentGroups = PropertiesParamUtil.getBoolean(typeSettingsProperties, request, "breadcrumbShowParentGroups", breadcrumbShowParentGroups);
		}
		%>

		<aui:input label="show-parent-sites-in-the-breadcrumb" name="TypeSettingsProperties--breadcrumbShowParentGroups--" type="toggle-switch" value="<%= breadcrumbShowParentGroups %>" />
	</div>

	<aui:script>
		function <portlet:namespace />isVisible(currentValue, value) {
			return currentValue != '';
		}

		Liferay.Util.toggleSelectBox('<portlet:namespace />publicLayoutSetPrototypeId', <portlet:namespace />isVisible, '<portlet:namespace />publicLayoutSetPrototypeIdOptions');
		Liferay.Util.toggleSelectBox('<portlet:namespace />privateLayoutSetPrototypeId', <portlet:namespace />isVisible, '<portlet:namespace />privateLayoutSetPrototypeIdOptions');

		Liferay.Util.toggleBoxes('<portlet:namespace />publicLayoutSetPrototypeLinkEnabled', '<portlet:namespace />publicLayoutSetPrototypeMergeAlert');
		Liferay.Util.toggleBoxes('<portlet:namespace />privateLayoutSetPrototypeLinkEnabled', '<portlet:namespace />privateLayoutSetPrototypeMergeAlert');
	</aui:script>

	<aui:script use="liferay-search-container">
		var createURL = function(href, value, onclick) {
			return '<a href="' + href + '"' + (onclick ? ' onclick="' + onclick + '" ' : '') + '>' + value + '</a>';
		};

		A.one('#<portlet:namespace />selectParentSiteLink').on(
			'click',
			function(event) {
				Liferay.Util.selectEntity(
					{
						dialog: {
							constrain: true,
							modal: true
						},
						id: '<portlet:namespace />selectGroup',
						title: '<liferay-ui:message arguments="site" key="select-x" />',

						<%
						PortletURL groupSelectorURL = PortletProviderUtil.getPortletURL(request, Group.class.getName(), PortletProvider.Action.BROWSE);

						groupSelectorURL.setParameter("includeCurrentGroup", Boolean.FALSE.toString());
						groupSelectorURL.setParameter("groupId", (group != null) ? String.valueOf(group.getGroupId()) : "0");
						groupSelectorURL.setParameter("eventName", liferayPortletResponse.getNamespace() + "selectGroup");
						groupSelectorURL.setWindowState(LiferayWindowState.POP_UP);
						%>

						uri: '<%= groupSelectorURL.toString() %>'
					},
					function(event) {
						var searchContainer = Liferay.SearchContainer.get('<portlet:namespace />parentGroupSearchContainer');

						var rowColumns = [];

						var href = '<portlet:renderURL><portlet:param name="mvcPath" value="/edit_site.jsp" /><portlet:param name="redirect" value="<%= currentURL %>" /></portlet:renderURL>&<portlet:namespace />groupId=' + event.groupid;

						rowColumns.push(createURL(href, event.groupdescriptivename));
						rowColumns.push(event.grouptype);
						rowColumns.push('<a class="modify-link" data-rowId="' + event.groupid + '" href="javascript:;"><%= UnicodeFormatter.toString(removeGroupIcon) %></a>');

						searchContainer.deleteRow(1, searchContainer.getData());
						searchContainer.addRow(rowColumns, event.groupid);
						searchContainer.updateDataStore(event.groupid);

						var membershipRestrictionContainer = A.one('#<portlet:namespace />membershipRestrictionContainer');

						membershipRestrictionContainer.show();
					}
				);
			}
		);

		var searchContainer = Liferay.SearchContainer.get('<portlet:namespace />parentGroupSearchContainer');

		searchContainer.get('contentBox').delegate(
			'click',
			function(event) {
				var link = event.currentTarget;

				var tr = link.ancestor('tr');

				searchContainer.deleteRow(tr, link.getAttribute('data-rowId'));

				var membershipRestrictionContainer = A.one('#<portlet:namespace />membershipRestrictionContainer');

				membershipRestrictionContainer.hide();
			},
			'.modify-link'
		);
	</aui:script>
</c:if>