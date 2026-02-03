/**
 * EmailJS Service
 * Handles contact form submissions via EmailJS
 */

import emailjs from 'emailjs-com';

// Initialize EmailJS on module load
const initializeEmailJS = () => {
    const publicKey = import.meta.env.VITE_EMAILJS_PUBLIC_KEY;

    if (!publicKey) {
        console.error('EmailJS public key not found in environment variables');
        return false;
    }

    try {
        emailjs.init(publicKey);
        console.log('EmailJS initialized successfully');
        return true;
    } catch (error) {
        console.error('Failed to initialize EmailJS:', error);
        return false;
    }
};

// Initialize on import
initializeEmailJS();

export interface ContactFormData {
    name: string;
    email: string;
    subject: string;
    message: string;
    phone?: string;
}

export interface EmailJSResponse {
    status: number;
    text: string;
}

/**
 * Send contact form email via EmailJS
 */
export const sendContactEmail = async (formData: ContactFormData): Promise<EmailJSResponse> => {
    try {
        const serviceId = import.meta.env.VITE_EMAILJS_SERVICE_ID;
        const templateId = import.meta.env.VITE_EMAILJS_TEMPLATE_ID;

        if (!serviceId || !templateId) {
            throw new Error('EmailJS configuration missing');
        }

        // Prepare template parameters
        const templateParams = {
            to_email: 'support@mquiz.uk',
            from_name: formData.name,
            from_email: formData.email,
            subject: formData.subject,
            message: formData.message,
            phone: formData.phone || 'Not provided',
            // Add timestamp
            timestamp: new Date().toLocaleString(),
        };

        // Send email
        const response = await emailjs.send(
            serviceId,
            templateId,
            templateParams
        );

        console.log('Email sent successfully:', response);
        return response;
    } catch (error) {
        console.error('Error sending email:', error);
        throw error;
    }
};

/**
 * Validate form data before sending
 */
export const validateContactForm = (formData: ContactFormData): { valid: boolean; errors: string[] } => {
    const errors: string[] = [];

    if (!formData.name || formData.name.trim().length === 0) {
        errors.push('Name is required');
    } else if (formData.name.length < 2) {
        errors.push('Name must be at least 2 characters');
    } else if (formData.name.length > 50) {
        errors.push('Name must be less than 50 characters');
    }

    if (!formData.email || formData.email.trim().length === 0) {
        errors.push('Email is required');
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
        errors.push('Please enter a valid email address');
    }

    if (!formData.subject || formData.subject.trim().length === 0) {
        errors.push('Subject is required');
    } else if (formData.subject.length < 5) {
        errors.push('Subject must be at least 5 characters');
    } else if (formData.subject.length > 100) {
        errors.push('Subject must be less than 100 characters');
    }

    if (!formData.message || formData.message.trim().length === 0) {
        errors.push('Message is required');
    } else if (formData.message.length < 10) {
        errors.push('Message must be at least 10 characters');
    } else if (formData.message.length > 5000) {
        errors.push('Message must be less than 5000 characters');
    }

    if (formData.phone && formData.phone.length > 0) {
        if (!/^[+\d\s\-()]+$/.test(formData.phone)) {
            errors.push('Please enter a valid phone number');
        }
    }

    return {
        valid: errors.length === 0,
        errors,
    };
};
