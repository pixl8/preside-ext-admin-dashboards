<cfscript>
	param name="args.icon"              type="string" default="";
	param name="args.title"             type="string" default="";
	param name="args.subTitle"          type="string" default="";
	param name="args.pageHeaderButtons" type="string" default="";
	param name="args.customImg"         type="string" default="";

	icon         = ReFind( "^fa\-", args.icon ) ? args.icon : "fa-#args.icon#";
	hasButtons   = Len( Trim( args.pageHeaderButtons ) );
	hasIcon      = Len( Trim( args.icon ) );
	hasCustomImg = Len( Trim( args.customImg ) );

	if( hasCustomImg ) {
		customImg = event.buildLink( assetId=args.customImg, derivative="customHeaderImg75px" );
		hasIcon   = false;
	}
</cfscript>

<cfoutput>
	<div class="page-header<cfif hasButtons> with-buttons</cfif><cfif hasIcon> with-icon</cfif><cfif hasCustomImg> with-image</cfif>">
		<h1>
			<cfif hasIcon>
				<i class="fa fa-fw #icon#"></i>
			<cfelseif hasCustomImg>
				<span class="user-image"><img src="#customImg#" alt=""></span>
			</cfif>

			#args.title#

			<cfif Len( Trim( args.subTitle ) )>
				<span class="sub-title">
					<small>
						<i class="fa fa-angle-double-right"></i>
						<span class="page-subtitle">#args.subTitle#</span>
					</small>
				</span>
			</cfif>
		</h1>
		<cfif hasButtons>
			<div class="page-header-button-group">
				#args.pageHeaderButtons#
			</div>
		</cfif>
	</div><!-- /.page-header -->
</cfoutput>