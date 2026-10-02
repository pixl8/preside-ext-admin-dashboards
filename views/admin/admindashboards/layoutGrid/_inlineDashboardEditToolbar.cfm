<cfscript>
	layoutAction   = LCase( args.dashboardLayoutAction ?: "viewrecord" );
	showToolbar    = isTrue( args.showInlineDashboardEditToolbar ?: "" );
	editLink       = args.inlineToolbarEditLink   ?: "";
	saveLink       = args.inlineToolbarSaveLink   ?: "";
	cancelLink     = args.inlineToolbarCancelLink ?: "";
	hasTempWidgets = isTrue( args.inlineToolbarHasTempWidgets ?: "" );
	cancelPrompt   = hasTempWidgets ? translateResource( uri="preside-objects.admin_dashboard:gridlayout.cancel.confirmation" ) : "";
	editLayoutBtn  = translateResource( "preside-objects.admin_dashboard:gridlayout.editlayout.btn" );
	cancelBtn      = translateResource( uri="preside-objects.admin_dashboard:gridlayout.cancel.btn" );
	saveBtn        = translateResource( uri="preside-objects.admin_dashboard:gridlayout.save.btn" );

	canShare       = isTrue( args.inlineToolbarCanShareDashboard  ?: "" );
	canEditRecord  = isTrue( args.inlineToolbarCanEditDashboard   ?: "" );
	canClone       = isTrue( args.inlineToolbarCanCloneDashboard  ?: "" );
	canDelete      = isTrue( args.inlineToolbarCanDeleteDashboard ?: "" );

	shareLink      = args.inlineToolbarShareLink      ?: "";
	editRecordLink = args.inlineToolbarEditRecordLink ?: "";
	cloneLink      = args.inlineToolbarCloneLink      ?: "";
	deleteLink     = args.inlineToolbarDeleteLink     ?: "";
	showDropdown   = ( canShare || canEditRecord || canClone || canDelete );
</cfscript>

<cfoutput>
	<cfif showToolbar>
		<div class="admin-dashboard-inline-edit-toolbar clearfix">
			<div class="pull-right btn-toolbar">
				<cfif layoutAction == "viewrecord">
					<cfif canEditRecord and Len( editLink )>
						<a class="btn btn-primary btn-sm" href="#HtmlEditFormat( editLink )#">#HtmlEditFormat( editLayoutBtn )#</a>
					</cfif>

					<cfif showDropdown>
						<div class="btn-group pull-right">
							<button type="button" class="btn btn-primary-invert btn-sm dropdown-toggle" data-toggle="dropdown">
								<i class="fa fa-fw fa-ellipsis-v"></i>
							</button>
							<ul class="dropdown-menu dropdown-menu-right">
								<cfif canShare and Len( shareLink )>
									<li>
										<a href="#HtmlEditFormat( shareLink )#">
											<i class="fa fa-fw fa-users"></i> #HtmlEditFormat( translateResource( uri="preside-objects.admin_dashboard:sharing.btn" ) )#
										</a>
									</li>
								</cfif>
								<cfif canEditRecord and Len( editRecordLink )>
									<li>
										<a href="#HtmlEditFormat( editRecordLink )#">
											<i class="fa fa-fw fa-pencil"></i> #HtmlEditFormat( translateResource( uri="preside-objects.admin_dashboard:gridlayout.edit.btn" ) )#
										</a>
									</li>
								</cfif>
								<cfif canClone and Len( cloneLink )>
									<li>
										<a href="#HtmlEditFormat( cloneLink )#">
											<i class="fa fa-fw fa-clone"></i> #HtmlEditFormat( translateResource( uri="preside-objects.admin_dashboard:gridlayout.clone.btn" ) )#
										</a>
									</li>
								</cfif>
								<cfif canDelete and Len( deleteLink )>
									<li>
										<a href="#HtmlEditFormat( deleteLink )#"
										   class="confirmation-prompt"
										   title="#HtmlEditFormat( translateResource( uri="preside-objects.admin_dashboard:gridlayout.delete.confirmation", data=[ args.name ?: "" ] ) )#"
										>
											<i class="fa fa-fw fa-trash-o"></i> #HtmlEditFormat( translateResource( uri="preside-objects.admin_dashboard:gridlayout.delete.btn" ) )#
										</a>
									</li>
								</cfif>
							</ul>
						</div>
					</cfif>
				<cfelse>
					<a class="btn btn-link btn-sm<cfif Len( cancelPrompt )> confirmation-prompt</cfif>" href="#HtmlEditFormat( cancelLink )#"<cfif Len( cancelPrompt )> title="#HtmlEditFormat( cancelPrompt )#"</cfif>>#HtmlEditFormat( cancelBtn )#</a>
					<a class="btn btn-primary btn-sm js-save-layout" href="#HtmlEditFormat( saveLink )#">#HtmlEditFormat( saveBtn )#</a>
					<a class="btn btn-default-invert btn-sm js-grid-auto-layout btn-grid-autolayout" href="##" title="">
						#renderView( view="/admin/admindashboards/layoutGrid/icon-grid-sm" )#
					</a>
				</cfif>
			</div>
		</div>
	</cfif>
</cfoutput>
