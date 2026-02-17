import { DocsLayout, type DocsLayoutProps } from "fumadocs-ui/layouts/docs";
import type { ReactNode } from "react";
import { baseOptions } from "@/app/layout.config";
import { source } from "@/lib/source";
import { DocsThemeHandler } from "@/components/docs/docs-theme-handler";
import { DocsRouteHandler } from "@/components/docs/docs-route-handler";
import "fumadocs-ui/css/ocean.css";
import "fumadocs-ui/css/preset.css";
import { NextProvider } from 'fumadocs-core/framework/next';
const docsOptions: DocsLayoutProps = {
    ...baseOptions,
    tree: source.pageTree,
};

export default function Layout({ children }: { children: ReactNode }) {
    return (
        <main>
            <DocsRouteHandler />
            <div className="docs-isolated-container relative">
                <div className="fixed left-[-200px] top-1/2 -translate-y-1/2 z-0 opacity-3 pointer-events-none select-none block"></div>

                <DocsThemeHandler />
                <NextProvider>
                    <DocsLayout {...docsOptions}>{children}</DocsLayout>
                </NextProvider>
            </div>
        </main>
    );
}