select tp.PLATFORM_NAME, tp.ENDIAN_FORMAT from v$database d, v$transportable_platform tp where d.platform_name=tp.platform_name;
