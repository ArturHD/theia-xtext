import { injectable, inject } from 'inversify';
import { Workspace, Languages, LanguageClientFactory, BaseLanguageClientContribution } from '@theia/languages/lib/browser';

@injectable()
export class DslClientContribution extends BaseLanguageClientContribution {

    readonly id = "dsl";
    readonly name = "DSL";

    constructor(
        @inject(Workspace) protected readonly workspace: Workspace,
        @inject(Languages) protected readonly languages: Languages,
        @inject(LanguageClientFactory) protected readonly languageClientFactory: LanguageClientFactory
    ) {
        super(workspace, languages, languageClientFactory);
    }

    protected get globPatterns() {
        return [
            '**/*.dsl', '**/*.py'
        ];
    }
}

// register language with monaco on first load
registerDSL();

export function registerDSL() {
    // initialize monaco
    monaco.languages.register({
        id: 'dsl',
        aliases: ['DSL', 'dsl'],
        extensions: ['.dsl', '.py'],
        mimetypes: ['text/dsl', 'text/py']
    })
    monaco.languages.setLanguageConfiguration('dsl', {
        comments: {
            lineComment: "//",
            blockComment: ['/*', '*/']
        },
        brackets: [['{', '}'], ['(', ')']],
        autoClosingPairs: [
            {
                open: '{',
                close: '}'
            },
            {
                open: '(',
                close: ')'
            }]
    })
   

}