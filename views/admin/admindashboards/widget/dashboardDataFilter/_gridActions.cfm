<cfscript>
	objectName = args.objectName ?: "";
	recordId   = args.id         ?: "";
</cfscript>

<cfoutput>
	<div class="action-buttons">
		<a class="row-link" href="#event.buildAdminLink( objectName=objectName, operation='viewRecord', recordId='recordId' )#" data-context-key="v" data-object="#objectName#" data-id="#recordId#">
			<i class="fa fa-fw fa-eye"></i>
		</a>
	</div>
</cfoutput>