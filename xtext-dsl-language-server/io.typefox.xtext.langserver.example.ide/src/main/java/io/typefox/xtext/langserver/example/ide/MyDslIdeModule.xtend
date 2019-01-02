/*
 * generated by Xtext 2.12.0-SNAPSHOT
 */
package io.typefox.xtext.langserver.example.ide
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalProvider

/**
 * Use this class to register ide components.
 */
class MyDslIdeModule extends AbstractMyDslIdeModule {
    // Register proprietary proposal provider
    // Added by AA based on this post: https://www.eclipse.org/forums/index.php/t/1074820/
    def Class<? extends IdeContentProposalProvider> bindIdeContentProposalProvider() {
		MyDslIdeProposalProvider
	}
}
