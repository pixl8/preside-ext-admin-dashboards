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
</cfscript>

<cfoutput>
	<cfif showToolbar>
		<div class="admin-dashboard-inline-edit-toolbar clearfix">
			<div class="pull-right btn-toolbar">
				<cfif layoutAction == "viewrecord">
					<a class="btn btn-primary btn-sm" href="#HtmlEditFormat( editLink )#">#HtmlEditFormat( editLayoutBtn )#</a>
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
