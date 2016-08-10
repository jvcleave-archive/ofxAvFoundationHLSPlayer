# AvFoundationPlayer

effort to add HLS to ofAvFoundationPlayer

https://github.com/openframeworks/openFrameworks/issues/1741


#To use:
Use Project Generator to create project

You will need to add this to the project Info.plist (edited version supplied)

````
<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
````