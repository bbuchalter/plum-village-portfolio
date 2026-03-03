import { useBlockProps, RichText } from '@wordpress/block-editor';

export default function save({ attributes }) {
    const { title, teacher, duration, description, mediaUrl } = attributes;
    const blockProps = useBlockProps.save();

    return (
        <div {...blockProps}>
            <RichText.Content tagName="h3" value={title} />
            <p className="dharma-talk__meta">
                {teacher}
                {duration && ` \u00B7 ${duration}`}
            </p>
            <RichText.Content
                tagName="div"
                className="dharma-talk__description"
                value={description}
            />
            {mediaUrl && (
                <a
                    className="dharma-talk__link"
                    href={mediaUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                >
                    Listen to this talk &rarr;
                </a>
            )}
        </div>
    );
}
