import { __ } from '@wordpress/i18n';
import {
    useBlockProps,
    RichText,
    InspectorControls,
} from '@wordpress/block-editor';
import { PanelBody, TextControl } from '@wordpress/components';

import './editor.scss';

export default function Edit({ attributes, setAttributes }) {
    const { title, teacher, duration, description, mediaUrl } = attributes;
    const blockProps = useBlockProps();

    return (
        <>
            <InspectorControls>
                <PanelBody
                    title={__('Talk Details', 'plum-village-blocks')}
                    initialOpen={true}
                >
                    <TextControl
                        label={__('Teacher', 'plum-village-blocks')}
                        value={teacher}
                        onChange={(value) =>
                            setAttributes({ teacher: value })
                        }
                    />
                    <TextControl
                        label={__('Duration', 'plum-village-blocks')}
                        value={duration}
                        onChange={(value) =>
                            setAttributes({ duration: value })
                        }
                        help={__(
                            'e.g. "45 min" or "1h 20min"',
                            'plum-village-blocks'
                        )}
                    />
                    <TextControl
                        label={__('Media URL', 'plum-village-blocks')}
                        value={mediaUrl}
                        onChange={(value) =>
                            setAttributes({ mediaUrl: value })
                        }
                        type="url"
                        help={__(
                            'Link to the audio or video recording.',
                            'plum-village-blocks'
                        )}
                    />
                </PanelBody>
            </InspectorControls>

            <div {...blockProps}>
                <RichText
                    tagName="h3"
                    value={title}
                    onChange={(value) => setAttributes({ title: value })}
                    placeholder={__(
                        'Dharma talk title...',
                        'plum-village-blocks'
                    )}
                />
                <p className="dharma-talk__meta">
                    {teacher || __('Teacher', 'plum-village-blocks')}
                    {duration && ` \u00B7 ${duration}`}
                </p>
                <RichText
                    tagName="div"
                    className="dharma-talk__description"
                    value={description}
                    onChange={(value) =>
                        setAttributes({ description: value })
                    }
                    placeholder={__(
                        'Write a description of this dharma talk...',
                        'plum-village-blocks'
                    )}
                />
                {mediaUrl && (
                    <p className="dharma-talk__link-preview">
                        {__('Listen to this talk \u2192', 'plum-village-blocks')}
                    </p>
                )}
            </div>
        </>
    );
}
