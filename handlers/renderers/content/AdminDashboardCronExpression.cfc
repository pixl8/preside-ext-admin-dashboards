/**
 * @feature adminDashboardSnapshots
 */
component {

	property name="cronUtil" inject="cronUtil";

	private string function default( event, rc, prc, args={} ) {
		var cron = Trim( args.data ?: "" );

		if ( !Len( cron ) ) {
			return "";
		}

		var description = ""

		try {
			description = cronUtil.describeCronTabExression( crontabExpression=cron, locale=event.getLanguage() );
		} catch ( any e ) {
			description = cron;
		}

		return '<span title="#HtmlEditFormat( cron )#">#HtmlEditFormat( description )#</span>';
	}

}