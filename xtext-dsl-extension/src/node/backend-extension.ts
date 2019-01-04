/*
 * Copyright (C) 2017 TypeFox and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 */

import { injectable, ContainerModule } from "inversify";
import { BaseLanguageServerContribution, LanguageServerContribution, IConnection } from "@theia/languages/lib/node";
import { createSocketConnection } from 'vscode-ws-jsonrpc/lib/server'
import * as path from 'path';
import * as net from 'net'


export default new ContainerModule(bind => {
    bind<LanguageServerContribution>(LanguageServerContribution).to(DSLContribution);
});

function getPort(): number | undefined {
    let arg = process.argv.filter(arg => arg.startsWith('--LSP_PORT='))[0]
    if (!arg) {
        return undefined
    } else {
        return Number.parseInt(arg.substring('--LSP_PORT='.length))
    }
}

/* Instructions for remove debugging (Artur Andrzejak, 4.01.2019):
Setup:
    10. Include the options for allowing remote debugging in JVM (lines A10, A20) in file 
        ...\DSL-workspace\DSL-eclipse-theia\xtext-dsl-extension\src\node\backend-extension.ts
    20. Rebuild the js/theia with "yarn" in the main project directory
    30. Start eclipse, and configure Run-> Debug Configuration -> Remote Java Application as follows (if not already there):
     - Config name: "LangServer with Theia (target is client)" (or similar)
     - Project: "io.typefox.xtext.langserver.example.ide"
     - Connection type: "Standard (Socket ***Listen***)" (Important: choose "... listen"
     - Port 8123 (same as in Line A20)
     - On Tab "Common", check (enable) for "Debug" on "Display on Favorites Menu" (then can start debug from toolbar)

Start:
    40. Start Eclipse debugger (via toolbar, right-click, "LangServer with Theia (target is client)"
     - In the debug perspective, you should see sth like "Waiting for vm to connect at port 8123..."
    50. Start theia application (e.g. via "start_theia.bat")
    60. Open browser, load http://127.0.0.1:3000/
    70. In a tab with "*.dsl" file, press ctrl+space => eclipse debugger should show the current breakpoint

*/

@injectable()
class DSLContribution extends BaseLanguageServerContribution {

    readonly id = "dsl";
    readonly name = "DSL";

    start(clientConnection: IConnection): void {
        let socketPort = getPort();
        if (socketPort) {
            const socket = new net.Socket()
            const serverConnection = createSocketConnection(socket, socket, () => {
                socket.destroy()
            });
            this.forward(clientConnection, serverConnection)
            socket.connect(socketPort)
        } else {
            const jar = path.resolve(__dirname, '../../build/dsl-language-server.jar');
    
            const command = 'java';
            
            // Modified for remote debugging by Artur Andrzejak on 4-01-2019
            const args: string[] = [
                '-Xdebug',      // Line A10
                '-Xrunjdwp:transport=dt_socket,address=127.0.0.1:8123',   // WORKS: target is client (Line A20)
                //  '-Xrunjdwp:transport=dt_socket,address=127.0.0.1:8123,suspend=y,server=y',   // target is server (not working)
                '-jar',
                jar
            ];
            // Original version
            // const args: string[] = [
            //    '-jar',
            //    jar
            //];
            const serverConnection = this.createProcessStreamConnection(command, args);
            this.forward(clientConnection, serverConnection);
        }
    }

    protected onDidFailSpawnProcess(error: Error): void {
        super.onDidFailSpawnProcess(error);
        console.error("Error starting DSL language server.", error)
    }

}



