import { __ } from '@wordpress/i18n';
import { useBlockProps, InspectorControls } from '@wordpress/block-editor';
import {
    PanelBody,
    RangeControl,
    ToggleControl,
} from '@wordpress/components';
import ServerSideRender from '@wordpress/server-side-render';

import './editor.scss';

export default function Edit({ attributes, setAttributes }) {
    const { columns, count, showExcerpt, showLessonCount } = attributes;
    const blockProps = useBlockProps();

    return (
        <>
            <InspectorControls>
                <PanelBody
                    title={__('Grid Settings', 'plum-village-blocks')}
                    initialOpen={true}
                >
                    <RangeControl
                        label={__('Columns', 'plum-village-blocks')}
                        value={columns}
                        onChange={(value) =>
                            setAttributes({ columns: value })
                        }
                        min={1}
                        max={4}
                    />
                    <RangeControl
                        label={__('Number of Courses', 'plum-village-blocks')}
                        value={count}
                        onChange={(value) =>
                            setAttributes({ count: value })
                        }
                        min={1}
                        max={12}
                    />
                </PanelBody>
                <PanelBody
                    title={__('Display Options', 'plum-village-blocks')}
                    initialOpen={true}
                >
                    <ToggleControl
                        label={__('Show Excerpt', 'plum-village-blocks')}
                        checked={showExcerpt}
                        onChange={(value) =>
                            setAttributes({ showExcerpt: value })
                        }
                    />
                    <ToggleControl
                        label={__(
                            'Show Lesson Count',
                            'plum-village-blocks'
                        )}
                        checked={showLessonCount}
                        onChange={(value) =>
                            setAttributes({ showLessonCount: value })
                        }
                    />
                </PanelBody>
            </InspectorControls>

            <div {...blockProps}>
                <ServerSideRender
                    block="plum-village/course-grid"
                    attributes={attributes}
                />
            </div>
        </>
    );
}
