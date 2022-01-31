import { LightningElement } from 'lwc';

export default class StatusCombo extends LightningElement {

    value = 'All';

    get options() {
        return [
            { label: 'Active', value: 'active' },
            { label: 'Completed', value: 'completed' },
            { label: 'Abandoned', value: 'abandoned' },
            { label: 'All', value: 'all' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }
}