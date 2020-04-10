variable "azure_ad_tenant_id" {
    type    = string
    default = ""
}

variable "azure_subscription_id" {
    type    = string
    default = ""
}

variable "service_principal_secret" {
    type    = string
    default = ""
}

variable "service_principal_id" {
    type    = string
    default = ""
}

variable "location" {
    type    = string
    default = "centralus"
}

variable "base_name" {
    type    = string
    default = "dummybase"
}

variable "stg_account_name" {
    type    = string
    default = ""
}

variable "resource_group_name" {
    type    = string
    default = ""
}