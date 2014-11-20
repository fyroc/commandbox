/**
 * Start an embedded CFML server.  Run command from the web root of the server.
 * .
 * {code:bash}
 * server start
 * {code}
 **/
component extends="commandbox.system.BaseCommand" aliases="start" excludeFromHelp=false {

	// DI
	property name="serverService" 	inject="ServerService";
	property name="packageService" 	inject="packageService";

	/**
	 * @port.hint            port number
	 * @openbrowser.hint     open a browser after starting
	 * @directory.hint       web root for this server
	 * @name.hint            short name for this server
	 * @stopPort.hint        stop socket listener port number
	 * @force.hint           force start if status is not stopped
	 * @debug.hint           sets debug log level
	 * @webConfigDir.hint    custom location for railo web context configuration
	 * @serverConfigDir.hint custom location for railo server configuration
	 * @libDirs.hint         comma separated list of extra lib directories for the Railo server
	 * @trayIcon.hint        path to .png file for tray icon
	 * @webXml.hint          path to web.xml file used to configure the Railo server
	 **/
	function run(
		Numeric port            = 0,
		Boolean openbrowser     = true,
		String  directory       = "",
		String  name            = "",
		Numeric stopPort        = 0,
		Boolean force           = false,
		Boolean debug           = false,
		String  webConfigDir    = "",
		String  serverConfigDir = "",
		String  libDirs         = "",
		String  trayIcon        = "",
		String  webXml          = ""
	){
		// Resolve path as used locally
		var webroot = fileSystemUtil.resolvePath( arguments.directory );

		// Discover by shortname or webroot and get server info
		var serverInfo = serverService.getServerInfoByDiscovery(
			directory 	= webroot,
			name		= arguments.name
		);

		// Was it found, or new server?
		if( structIsEmpty( serverInfo ) ){
			// We need a new entry
			serverInfo = serverService.getServerInfo( webroot );
		}

		// Get package descriptor for overrides 
		var boxJSON = packageService.readPackageDescriptor( webroot );

		// Update data from arguments
		serverInfo.webroot 	= webroot;
		serverInfo.debug 	= arguments.debug;
		serverInfo.name 	= arguments.name is "" ? listLast( webroot, "\/" ) : arguments.name;
			
		// we don't want to changes the ports if we're doing stuff already
		if( serverInfo.status is "stopped" || arguments.force ){
			if( arguments.port != 0 ){
				serverInfo.port = arguments.port;
			}
			if( arguments.stopPort != 0 ){
				serverInfo.stopsocket = arguments.stopPort;
			}
		}

		// If no port, check box descriptor for port.
		if( !serverInfo.port ) {
			serverInfo.port = boxJSON.defaultPort;
		}

		// Setup serverinfo according to params
		if ( Len( Trim( arguments.webConfigDir    ) ) ) { serverInfo.webConfigDir    = arguments.webConfigDir;    }
		if ( Len( Trim( arguments.serverConfigDir ) ) ) { serverInfo.serverConfigDir = arguments.serverConfigDir; }
		if ( Len( Trim( arguments.libDirs         ) ) ) { serverInfo.libDirs         = arguments.libDirs;         }
		if ( Len( Trim( arguments.trayIcon        ) ) ) { serverInfo.trayIcon        = arguments.trayIcon;        }
		if ( Len( Trim( arguments.webXml          ) ) ) { serverInfo.webXml          = arguments.webXml;          }

		// startup the service using server info struct, the start service takes care of persisting updated params
		return serverService.start( 
			serverInfo 	= serverInfo,
			openBrowser = arguments.openbrowser,
			force		= arguments.force,
			debug 		= arguments.debug 
		);
	}

}